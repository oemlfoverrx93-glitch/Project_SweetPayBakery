package com.sweetpay.dao;

import com.sweetpay.model.Payment;
import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

public class PaymentDAO {

    private static final String CREATE_PAYMENTS_TABLE_SQL =
            "IF OBJECT_ID('dbo.payments', 'U') IS NULL "
            + "BEGIN "
            + "CREATE TABLE payments ("
            + "payment_id INT IDENTITY(1,1) PRIMARY KEY, "
            + "order_id INT NOT NULL UNIQUE, "
            + "payment_method NVARCHAR(30) NOT NULL "
            + "CHECK (payment_method IN ('COD', 'BANK_TRANSFER', 'MOMO', 'VNPAY')), "
            + "amount DECIMAL(18,2) NOT NULL DEFAULT 0, "
            + "payment_status NVARCHAR(30) NOT NULL DEFAULT 'pending' "
            + "CHECK (payment_status IN ('pending', 'unpaid', 'paid', 'failed', 'refunded')), "
            + "transaction_code NVARCHAR(100) NULL, "
            + "paid_at DATETIME NULL, "
            + "created_at DATETIME NOT NULL DEFAULT GETDATE(), "
            + "FOREIGN KEY (order_id) REFERENCES orders(order_id)"
            + ") "
            + "END";

    public void createPaymentsTableIfMissing() {
        try (Connection conn = DBContext.getConnection()) {
            createPaymentsTableIfMissing(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void createPaymentsTableIfMissing(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate(CREATE_PAYMENTS_TABLE_SQL);
        }
    }

    public int insertPayment(Payment payment) {
        if (payment == null) {
            return -1;
        }

        try (Connection conn = DBContext.getConnection()) {
            createPaymentsTableIfMissing(conn);
            return insertPayment(conn, payment);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public int insertPayment(Connection conn, Payment payment) throws SQLException {
        if (payment == null || payment.getOrderId() <= 0) {
            return -1;
        }

        String insertSql = "INSERT INTO payments (order_id, payment_method, amount, payment_status, transaction_code, paid_at, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String method = normalizePaymentMethod(payment.getPaymentMethod());
        String status = normalizePaymentStatus(payment.getPaymentStatus());

        if (status == null) {
            status = "COD".equals(method) ? "unpaid" : "pending";
        }

        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getOrderId());
            ps.setString(2, method);
            ps.setBigDecimal(3, defaultMoney(payment.getAmount()));
            ps.setString(4, status);
            ps.setString(5, payment.getTransactionCode());
            ps.setTimestamp(6, payment.getPaidAt());
            ps.setTimestamp(7, payment.getCreatedAt() != null ? payment.getCreatedAt() : new Timestamp(System.currentTimeMillis()));
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }

    public Payment getPaymentByOrderId(int orderId) {
        String sql = "SELECT TOP 1 payment_id, order_id, payment_method, amount, payment_status, transaction_code, paid_at, created_at "
                + "FROM payments WHERE order_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPayment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Payment getByOrderId(int orderId) {
        return getPaymentByOrderId(orderId);
    }

    public boolean updatePaymentStatus(int paymentId, String paymentStatus) {
        String status = normalizePaymentStatus(paymentStatus);
        if (paymentId <= 0 || status == null) {
            return false;
        }

        String sql = "UPDATE payments SET payment_status = ?, paid_at = ? WHERE payment_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setTimestamp(2, "paid".equals(status) ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setInt(3, paymentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentStatusByOrderId(int orderId, String paymentStatus) {
        String status = normalizePaymentStatus(paymentStatus);
        if (orderId <= 0 || status == null) {
            return false;
        }

        String sql = "UPDATE payments SET payment_status = ?, paid_at = ? WHERE order_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setTimestamp(2, "paid".equals(status) ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentStatusByOrderId(Connection conn, int orderId, String paymentStatus) throws SQLException {
        String status = normalizePaymentStatus(paymentStatus);
        if (conn == null || orderId <= 0 || status == null) {
            return false;
        }

        String sql = "UPDATE payments SET payment_status = ?, paid_at = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setTimestamp(2, "paid".equals(status) ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    private Payment mapPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentId(rs.getInt("payment_id"));
        payment.setOrderId(rs.getInt("order_id"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setPaymentStatus(rs.getString("payment_status"));
        payment.setTransactionCode(rs.getString("transaction_code"));
        payment.setPaidAt(rs.getTimestamp("paid_at"));
        payment.setCreatedAt(rs.getTimestamp("created_at"));
        return payment;
    }

    private String normalizePaymentMethod(String paymentMethod) {
        if (paymentMethod == null) {
            return "COD";
        }

        String value = paymentMethod.trim().toUpperCase();
        if ("COD".equals(value) || "BANK_TRANSFER".equals(value) || "MOMO".equals(value) || "VNPAY".equals(value)) {
            return value;
        }
        return "COD";
    }

    private String normalizePaymentStatus(String paymentStatus) {
        if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
            return null;
        }

        String value = paymentStatus.trim().toLowerCase();
        if ("pending".equals(value)
                || "unpaid".equals(value)
                || "paid".equals(value)
                || "failed".equals(value)
                || "refunded".equals(value)) {
            return value;
        }
        return null;
    }

    private BigDecimal defaultMoney(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}
