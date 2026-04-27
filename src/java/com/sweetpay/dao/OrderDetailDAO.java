package com.sweetpay.dao;

import com.sweetpay.model.OrderDetail;
import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailDAO {

    private static final String CREATE_ORDER_DETAILS_TABLE_SQL =
            "IF OBJECT_ID('dbo.order_details', 'U') IS NULL "
            + "BEGIN "
            + "CREATE TABLE order_details ("
            + "order_detail_id INT IDENTITY(1,1) PRIMARY KEY, "
            + "order_id INT NOT NULL, "
            + "product_id INT NOT NULL, "
            + "quantity INT NOT NULL CHECK (quantity > 0), "
            + "unit_price DECIMAL(18,2) NOT NULL, "
            + "line_total AS (quantity * unit_price), "
            + "CONSTRAINT UQ_order_details_order_product UNIQUE (order_id, product_id), "
            + "FOREIGN KEY (order_id) REFERENCES orders(order_id), "
            + "FOREIGN KEY (product_id) REFERENCES products(product_id)"
            + ") "
            + "END";

    public void createOrderDetailsTableIfMissing() {
        try (Connection conn = DBContext.getConnection()) {
            createOrderDetailsTableIfMissing(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void createOrderDetailsTableIfMissing(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate(CREATE_ORDER_DETAILS_TABLE_SQL);
        }
    }

    public boolean insertOrderDetail(OrderDetail detail) {
        if (!isValidDetail(detail)) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            createOrderDetailsTableIfMissing(conn);

            boolean inserted = insertOrderDetail(conn, detail);
            if (inserted) {
                conn.commit();
            } else {
                conn.rollback();
            }
            return inserted;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return false;
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    public boolean insertOrderDetail(Connection conn, OrderDetail detail) throws SQLException {
        if (!isValidDetail(detail)) {
            return false;
        }

        String sql = "INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, detail.getOrderId());
            ps.setInt(2, detail.getProductId());
            ps.setInt(3, detail.getQuantity());
            ps.setBigDecimal(4, defaultMoney(detail.getUnitPrice()));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean insertBatch(List<OrderDetail> details) {
        if (details == null || details.isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            createOrderDetailsTableIfMissing(conn);

            boolean inserted = insertBatch(conn, details);
            if (inserted) {
                conn.commit();
            } else {
                conn.rollback();
            }
            return inserted;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return false;
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    public boolean insertBatch(Connection conn, List<OrderDetail> details) throws SQLException {
        if (details == null || details.isEmpty()) {
            return false;
        }

        String sql = "INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int count = 0;
            for (OrderDetail detail : details) {
                if (!isValidDetail(detail)) {
                    continue;
                }
                ps.setInt(1, detail.getOrderId());
                ps.setInt(2, detail.getProductId());
                ps.setInt(3, detail.getQuantity());
                ps.setBigDecimal(4, defaultMoney(detail.getUnitPrice()));
                ps.addBatch();
                count++;
            }

            if (count == 0) {
                return false;
            }

            int[] results = ps.executeBatch();
            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;
        }
    }

    public List<OrderDetail> getDetailsByOrderId(int orderId) {
        List<OrderDetail> details = new ArrayList<>();
        String sql = "SELECT order_detail_id, order_id, product_id, quantity, unit_price, line_total "
                + "FROM order_details WHERE order_id = ? ORDER BY order_detail_id ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setOrderDetailId(rs.getInt("order_detail_id"));
                    detail.setOrderId(rs.getInt("order_id"));
                    detail.setProductId(rs.getInt("product_id"));
                    detail.setQuantity(rs.getInt("quantity"));
                    detail.setUnitPrice(rs.getBigDecimal("unit_price"));
                    detail.setLineTotal(rs.getBigDecimal("line_total"));
                    details.add(detail);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    private boolean isValidDetail(OrderDetail detail) {
        return detail != null
                && detail.getOrderId() > 0
                && detail.getProductId() > 0
                && detail.getQuantity() > 0;
    }

    private BigDecimal defaultMoney(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
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

    private void resetAutoCommitAndClose(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        try {
            conn.close();
        } catch (SQLException closeEx) {
            closeEx.printStackTrace();
        }
    }
}
