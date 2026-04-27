package com.sweetpay.dao;

import com.sweetpay.model.Order;
import com.sweetpay.model.OrderDetail;
import com.sweetpay.model.Payment;
import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private static final String CREATE_ORDERS_TABLE_SQL =
            "IF OBJECT_ID('dbo.orders', 'U') IS NULL "
            + "BEGIN "
            + "CREATE TABLE orders ("
            + "order_id INT IDENTITY(1,1) PRIMARY KEY, "
            + "user_id INT NOT NULL, "
            + "voucher_id INT NULL, "
            + "order_code NVARCHAR(50) NOT NULL UNIQUE, "
            + "recipient_name NVARCHAR(100) NOT NULL, "
            + "recipient_phone NVARCHAR(20) NOT NULL, "
            + "shipping_address NVARCHAR(255) NOT NULL, "
            + "receive_method NVARCHAR(50) NULL CHECK (receive_method IN ('delivery', 'pickup')), "
            + "receive_time DATETIME NULL, "
            + "subtotal DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0), "
            + "discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0), "
            + "shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0), "
            + "total_amount AS (CASE WHEN subtotal - discount_amount + shipping_fee < 0 THEN 0 ELSE subtotal - discount_amount + shipping_fee END), "
            + "order_status NVARCHAR(30) NOT NULL DEFAULT 'pending' "
            + "CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'shipping', 'ready_for_pickup', 'completed', 'cancelled')), "
            + "note NVARCHAR(255) NULL, "
            + "order_date DATETIME NOT NULL DEFAULT GETDATE(), "
            + "FOREIGN KEY (user_id) REFERENCES users(user_id), "
            + "FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id)"
            + ") "
            + "END";

    private static final String ORDER_SELECT_COLUMNS =
            "o.order_id, o.user_id, o.voucher_id, o.order_code, o.recipient_name, o.recipient_phone, "
            + "o.shipping_address, o.receive_method, o.receive_time, o.subtotal, o.discount_amount, "
            + "o.shipping_fee, o.total_amount, o.order_status, ISNULL(p.payment_status, 'unpaid') AS payment_status, "
            + "o.note, o.order_date";

    private static final String ORDER_SELECT_FROM =
            " FROM orders o LEFT JOIN payments p ON p.order_id = o.order_id ";

    public void createOrderTableIfMissing() {
        try (Connection conn = DBContext.getConnection()) {
            createOrderTableIfMissing(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void createOrderTableIfMissing(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate(CREATE_ORDERS_TABLE_SQL);
        }
    }

    public int createOrder(Order order) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            createOrderTableIfMissing(conn);
            return insertOrder(conn, order);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeConnection(conn);
        }
    }

    public int createOrder(Order order, List<OrderDetail> orderDetails) {
        return placeOrder(order, orderDetails, null);
    }

    public int placeOrder(Order order, List<OrderDetail> orderDetails, Payment payment) {
        if (order == null || orderDetails == null || orderDetails.isEmpty()) {
            return -1;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
            PaymentDAO paymentDAO = new PaymentDAO();
            VoucherDAO voucherDAO = new VoucherDAO();

            createOrderTableIfMissing(conn);
            orderDetailDAO.createOrderDetailsTableIfMissing(conn);
            paymentDAO.createPaymentsTableIfMissing(conn);

            if (order.getVoucherId() != null && order.getVoucherId() > 0) {
                if (!voucherDAO.decreaseVoucherQuantity(conn, order.getVoucherId())) {
                    conn.rollback();
                    return -1;
                }
            }

            int orderId = insertOrder(conn, order);
            if (orderId <= 0) {
                conn.rollback();
                return -1;
            }

            for (OrderDetail orderDetail : orderDetails) {
                if (orderDetail != null) {
                    orderDetail.setOrderId(orderId);
                }
            }

            if (!orderDetailDAO.insertBatch(conn, orderDetails)) {
                conn.rollback();
                return -1;
            }

            if (!decreaseInventoryForOrder(conn, orderDetails)) {
                conn.rollback();
                return -1;
            }

            if (payment != null) {
                payment.setOrderId(orderId);
                if (payment.getAmount() == null) {
                    payment.setAmount(defaultMoney(order.getTotalAmount()));
                }

                int paymentId = paymentDAO.insertPayment(conn, payment);
                if (paymentId <= 0) {
                    conn.rollback();
                    return -1;
                }
            }

            conn.commit();
            return orderId;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return -1;
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    public Order getOrderById(int orderId) {
        String sql = "SELECT " + ORDER_SELECT_COLUMNS + ORDER_SELECT_FROM + "WHERE o.order_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            createOrderTableIfMissing(conn);
            new PaymentDAO().createPaymentsTableIfMissing(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Order order = mapOrder(rs);
                        order.setOrderDetails(new OrderDetailDAO().getDetailsByOrderId(orderId));
                        return order;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT " + ORDER_SELECT_COLUMNS + ORDER_SELECT_FROM
                + "WHERE o.user_id = ? ORDER BY o.order_date DESC";

        try (Connection conn = DBContext.getConnection()) {
            createOrderTableIfMissing(conn);
            new PaymentDAO().createPaymentsTableIfMissing(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        orders.add(mapOrder(rs));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<Order> getAllOrders() {
        return getAllOrders(null);
    }

    public List<Order> getAllOrders(String status) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT " + ORDER_SELECT_COLUMNS + ORDER_SELECT_FROM;
        boolean hasStatus = status != null && !status.trim().isEmpty();
        if (hasStatus) {
            sql += " WHERE o.order_status = ?";
        }
        sql += " ORDER BY o.order_date DESC";

        try (Connection conn = DBContext.getConnection()) {
            createOrderTableIfMissing(conn);
            new PaymentDAO().createPaymentsTableIfMissing(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (hasStatus) {
                    ps.setString(1, status.trim().toLowerCase());
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        orders.add(mapOrder(rs));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<Order> getAllOrdersForAdmin(String orderStatus, String paymentStatus, String keyword) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT " + ORDER_SELECT_COLUMNS + ORDER_SELECT_FROM + "WHERE 1=1");

        String normalizedOrderStatus = normalizeOrderStatusFilter(orderStatus);
        String normalizedPaymentStatus = normalizePaymentStatusFilter(paymentStatus);
        String normalizedKeyword = keyword == null ? null : keyword.trim();

        if (normalizedOrderStatus != null) {
            sql.append(" AND o.order_status = ?");
        }
        if (normalizedPaymentStatus != null) {
            sql.append(" AND ISNULL(p.payment_status, 'unpaid') = ?");
        }
        if (normalizedKeyword != null && !normalizedKeyword.isEmpty()) {
            sql.append(" AND (o.order_code LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?)");
        }
        sql.append(" ORDER BY o.order_date DESC");

        try (Connection conn = DBContext.getConnection()) {
            createOrderTableIfMissing(conn);
            new PaymentDAO().createPaymentsTableIfMissing(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                if (normalizedOrderStatus != null) {
                    ps.setString(idx++, normalizedOrderStatus);
                }
                if (normalizedPaymentStatus != null) {
                    ps.setString(idx++, normalizedPaymentStatus);
                }
                if (normalizedKeyword != null && !normalizedKeyword.isEmpty()) {
                    String like = "%" + normalizedKeyword + "%";
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        orders.add(mapOrder(rs));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return orders;
    }

    public Order getOrderByIdForAdmin(int orderId) {
        return getOrderById(orderId);
    }

    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentStatusOnOrder(int orderId, String paymentStatus) {
        String normalized = normalizePaymentStatusFilter(paymentStatus);
        if (orderId <= 0 || normalized == null) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            PaymentDAO paymentDAO = new PaymentDAO();
            paymentDAO.createPaymentsTableIfMissing(conn);

            boolean updated = paymentDAO.updatePaymentStatusByOrderId(conn, orderId, normalized);
            if (!updated) {
                Payment payment = new Payment();
                payment.setOrderId(orderId);
                payment.setPaymentMethod("COD");
                payment.setAmount(getOrderTotalAmount(conn, orderId));
                payment.setPaymentStatus(normalized);
                updated = paymentDAO.insertPayment(conn, payment) > 0;
            }

            conn.commit();
            return updated;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return false;
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    public boolean updateStatusesForAdmin(int orderId, String orderStatus, String paymentStatus) {
        if (orderId <= 0) {
            return false;
        }

        String normalizedOrderStatus = normalizeOrderStatusFilter(orderStatus);
        String normalizedPaymentStatus = normalizePaymentStatusFilter(paymentStatus);
        if (normalizedOrderStatus == null && normalizedPaymentStatus == null) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            boolean anyUpdated = false;

            if (normalizedOrderStatus != null) {
                String orderSql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                    ps.setString(1, normalizedOrderStatus);
                    ps.setInt(2, orderId);
                    anyUpdated = ps.executeUpdate() > 0 || anyUpdated;
                }
            }

            if (normalizedPaymentStatus != null) {
                PaymentDAO paymentDAO = new PaymentDAO();
                paymentDAO.createPaymentsTableIfMissing(conn);
                boolean paymentRowUpdated = paymentDAO.updatePaymentStatusByOrderId(conn, orderId, normalizedPaymentStatus);
                if (!paymentRowUpdated) {
                    Payment payment = new Payment();
                    payment.setOrderId(orderId);
                    payment.setPaymentMethod("COD");
                    payment.setAmount(getOrderTotalAmount(conn, orderId));
                    payment.setPaymentStatus(normalizedPaymentStatus);
                    payment.setTransactionCode(null);
                    paymentRowUpdated = paymentDAO.insertPayment(conn, payment) > 0;
                }
                anyUpdated = paymentRowUpdated || anyUpdated;
            }

            conn.commit();
            return anyUpdated;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return false;
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        return new OrderDetailDAO().getDetailsByOrderId(orderId);
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setUserId(rs.getInt("user_id"));

        int voucherId = rs.getInt("voucher_id");
        if (rs.wasNull()) {
            order.setVoucherId(null);
        } else {
            order.setVoucherId(voucherId);
        }

        order.setOrderCode(rs.getString("order_code"));
        order.setRecipientName(rs.getString("recipient_name"));
        order.setRecipientPhone(rs.getString("recipient_phone"));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setReceiveMethod(rs.getString("receive_method"));
        order.setReceiveTime(rs.getTimestamp("receive_time"));
        order.setSubtotal(rs.getBigDecimal("subtotal"));
        order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        order.setShippingFee(rs.getBigDecimal("shipping_fee"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setOrderStatus(rs.getString("order_status"));
        order.setPaymentStatus(rs.getString("payment_status"));
        order.setNote(rs.getString("note"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        return order;
    }

    private int insertOrder(Connection conn, Order order) throws SQLException {
        if (order == null) {
            return -1;
        }

        String insertOrderSql = "INSERT INTO orders ("
                + "user_id, voucher_id, order_code, recipient_name, recipient_phone, shipping_address, "
                + "receive_method, receive_time, subtotal, discount_amount, shipping_fee, "
                + "order_status, note, order_date"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement psOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
            BigDecimal subtotal = defaultMoney(order.getSubtotal());
            BigDecimal discount = defaultMoney(order.getDiscountAmount());
            BigDecimal shipping = defaultMoney(order.getShippingFee());
            BigDecimal total = order.getTotalAmount();
            if (total == null) {
                total = subtotal.subtract(discount).add(shipping);
            }
            order.setTotalAmount(total);

            psOrder.setInt(1, order.getUserId());
            setNullableInt(psOrder, 2, order.getVoucherId());
            psOrder.setString(3, defaultString(order.getOrderCode(), generateOrderCode()));
            psOrder.setString(4, defaultString(order.getRecipientName(), "Guest"));
            psOrder.setString(5, defaultString(order.getRecipientPhone(), "N/A"));
            psOrder.setString(6, defaultString(order.getShippingAddress(), "N/A"));
            psOrder.setString(7, defaultString(order.getReceiveMethod(), "delivery"));
            psOrder.setTimestamp(8, order.getReceiveTime());
            psOrder.setBigDecimal(9, subtotal);
            psOrder.setBigDecimal(10, discount);
            psOrder.setBigDecimal(11, shipping);
            psOrder.setString(12, defaultString(order.getOrderStatus(), "pending"));
            psOrder.setString(13, order.getNote());
            psOrder.setTimestamp(14, order.getOrderDate() != null ? order.getOrderDate() : new Timestamp(System.currentTimeMillis()));

            psOrder.executeUpdate();

            try (ResultSet rs = psOrder.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }

    private BigDecimal defaultMoney(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    private boolean decreaseInventoryForOrder(Connection conn, List<OrderDetail> orderDetails) throws SQLException {
        if (conn == null || orderDetails == null || orderDetails.isEmpty()) {
            return true;
        }
        if (!inventoryTableExists(conn)) {
            return true;
        }

        String sql = "UPDATE inventory "
                + "SET quantity_in_stock = quantity_in_stock - ?, updated_at = GETDATE() "
                + "WHERE product_id = ? AND quantity_in_stock >= ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (OrderDetail detail : orderDetails) {
                if (detail == null || detail.getProductId() <= 0 || detail.getQuantity() <= 0) {
                    continue;
                }
                ps.setInt(1, detail.getQuantity());
                ps.setInt(2, detail.getProductId());
                ps.setInt(3, detail.getQuantity());
                int updatedRows = ps.executeUpdate();
                if (updatedRows <= 0) {
                    if (!inventoryRowExists(conn, detail.getProductId())) {
                        continue;
                    }
                    return false;
                }
            }
        }

        return true;
    }

    private boolean inventoryTableExists(Connection conn) {
        String sql = "SELECT OBJECT_ID('dbo.inventory', 'U') AS table_id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getObject("table_id") != null;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private boolean inventoryRowExists(Connection conn, int productId) {
        if (conn == null || productId <= 0) {
            return false;
        }
        String sql = "SELECT 1 FROM inventory WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private BigDecimal getOrderTotalAmount(Connection conn, int orderId) throws SQLException {
        String sql = "SELECT total_amount FROM orders WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal value = rs.getBigDecimal("total_amount");
                    return value != null ? value : BigDecimal.ZERO;
                }
            }
        }
        return BigDecimal.ZERO;
    }

    private String defaultString(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }

    private String generateOrderCode() {
        return "OD" + System.currentTimeMillis();
    }

    private String normalizeOrderStatusFilter(String status) {
        if (status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status.trim())) {
            return null;
        }
        String value = status.trim().toLowerCase();
        if ("pending".equals(value)
                || "confirmed".equals(value)
                || "preparing".equals(value)
                || "shipping".equals(value)
                || "ready_for_pickup".equals(value)
                || "completed".equals(value)
                || "cancelled".equals(value)) {
            return value;
        }
        return null;
    }

    private String normalizePaymentStatusFilter(String status) {
        if (status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status.trim())) {
            return null;
        }
        String value = status.trim().toLowerCase();
        if ("pending".equals(value)
                || "unpaid".equals(value)
                || "paid".equals(value)
                || "failed".equals(value)
                || "refunded".equals(value)) {
            return value;
        }
        return null;
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
            return;
        }
        ps.setInt(index, value);
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (SQLException rollbackEx) {
            rollbackEx.printStackTrace();
        }
    }

    private void closeConnection(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.close();
        } catch (SQLException closeEx) {
            closeEx.printStackTrace();
        }
    }

    private void resetAutoCommitAndClose(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        closeConnection(conn);
    }
}
