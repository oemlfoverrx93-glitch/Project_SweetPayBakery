package com.sweetpay.dao;

import com.sweetpay.model.CustomerSpending;
import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AdminDashboardDAO {

    public int getTotalProducts() {
        return queryInt("SELECT COUNT(*) FROM products WHERE status = 1");
    }

    public int getTotalOrders() {
        return queryInt("SELECT COUNT(*) FROM orders");
    }

    public int getTotalUsers() {
        return queryInt("SELECT COUNT(*) FROM users WHERE status = 1");
    }

    public BigDecimal getCompletedRevenue() {
        String sql = "SELECT ISNULL(SUM(o.total_amount), 0) FROM orders o JOIN payments p ON p.order_id=o.order_id WHERE o.order_status='completed' AND p.payment_status='paid'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public List<CustomerSpending> getTopCustomersBySpending(Timestamp startInclusive, Timestamp endExclusive, int limit) {
        List<CustomerSpending> customers = new ArrayList<>();
        int safeLimit = Math.max(1, Math.min(limit, 100));
        String sql = "SELECT TOP " + safeLimit + " "
                + "u.user_id, u.full_name, u.email, u.phone, "
                + "COUNT(o.order_id) AS order_count, "
                + "ISNULL(SUM(o.total_amount), 0) AS total_spent, "
                + "MIN(o.order_date) AS first_order_date, "
                + "MAX(o.order_date) AS last_order_date "
                + "FROM users u "
                + "INNER JOIN roles r ON r.role_id = u.role_id "
                + "INNER JOIN orders o ON o.user_id = u.user_id "
                + "INNER JOIN payments p ON p.order_id=o.order_id AND p.payment_status='paid' "
                + "WHERE r.role_name = 'customer' "
                + "AND o.order_status = 'completed' "
                + "AND o.order_date >= ? "
                + "AND o.order_date < ? "
                + "GROUP BY u.user_id, u.full_name, u.email, u.phone "
                + "ORDER BY total_spent DESC, order_count DESC, last_order_date DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, startInclusive);
            ps.setTimestamp(2, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    customers.add(mapCustomerSpending(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return customers;
    }

    private int queryInt(String sql) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private CustomerSpending mapCustomerSpending(ResultSet rs) throws SQLException {
        CustomerSpending customer = new CustomerSpending();
        customer.setUserId(rs.getInt("user_id"));
        customer.setFullName(rs.getString("full_name"));
        customer.setEmail(rs.getString("email"));
        customer.setPhone(rs.getString("phone"));
        customer.setOrderCount(rs.getInt("order_count"));
        customer.setTotalSpent(rs.getBigDecimal("total_spent"));
        customer.setFirstOrderDate(rs.getTimestamp("first_order_date"));
        customer.setLastOrderDate(rs.getTimestamp("last_order_date"));
        return customer;
    }
}
