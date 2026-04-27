package com.sweetpay.dao;

import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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
        String sql = "SELECT ISNULL(SUM(total_amount), 0) FROM orders WHERE order_status = 'completed'";
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
}
