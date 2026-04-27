package com.sweetpay.dao;

import com.sweetpay.model.User;
import com.sweetpay.util.DBContext;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private static final String BASE_SELECT
            = "SELECT u.user_id, u.role_id, r.role_name, u.full_name, u.email, u.phone, u.password_hash, "
            + "u.address, u.status, u.created_at, u.google_sub, u.auth_provider, u.avatar_url, "
            + "u.email_verified, u.last_login_at "
            + "FROM users u "
            + "INNER JOIN roles r ON u.role_id = r.role_id ";

    public User findById(int userId) {
        String sql = BASE_SELECT + "WHERE u.user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        String sql = BASE_SELECT + "WHERE u.email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByGoogleSub(String googleSub) {
        if (googleSub == null || googleSub.trim().isEmpty()) {
            return null;
        }

        String sql = BASE_SELECT + "WHERE u.google_sub = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleSub.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User authenticateLocal(String email, String rawPassword) {
        User user = findByEmail(email);
        if (user == null || !user.isStatus()) {
            return null;
        }
        return verifyPassword(rawPassword, user.getPasswordHash()) ? user : null;
    }

    public User createGoogleUser(String fullName, String email, String googleSub, String avatarUrl, boolean emailVerified) {
        if (email == null || email.trim().isEmpty() || googleSub == null || googleSub.trim().isEmpty()) {
            return null;
        }

        int customerRoleId = getRoleIdByName("customer");
        String displayName = fullName == null || fullName.trim().isEmpty() ? email.trim() : fullName.trim();

        String sql = "INSERT INTO users(role_id, full_name, email, phone, password_hash, address, status, created_at, "
                + "google_sub, auth_provider, avatar_url, email_verified, last_login_at) "
                + "VALUES (?, ?, ?, NULL, ?, NULL, 1, GETDATE(), ?, 'google', ?, ?, GETDATE())";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerRoleId);
            ps.setString(2, displayName);
            ps.setString(3, email.trim());
            ps.setString(4, "GOOGLE_LOGIN_NO_PASSWORD");
            ps.setString(5, googleSub.trim());
            ps.setString(6, normalizeNullable(avatarUrl));
            ps.setBoolean(7, emailVerified);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                return findByGoogleSub(googleSub);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean linkGoogleAccount(int userId, String googleSub, String avatarUrl, boolean emailVerified) {
        if (userId <= 0 || googleSub == null || googleSub.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE users "
                + "SET google_sub = ?, auth_provider = 'google', avatar_url = ?, email_verified = ?, last_login_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleSub.trim());
            ps.setString(2, normalizeNullable(avatarUrl));
            ps.setBoolean(3, emailVerified);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateLastLogin(int userId) {
        if (userId <= 0) {
            return false;
        }

        String sql = "UPDATE users SET last_login_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> getUsersForAdmin(String keyword, String statusFilter) {
        List<User> users = new ArrayList<>();

        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        String normalizedStatus = statusFilter == null ? "all" : statusFilter.trim().toLowerCase();
        boolean hasKeyword = !normalizedKeyword.isEmpty();
        boolean activeOnly = "active".equals(normalizedStatus);
        boolean inactiveOnly = "inactive".equals(normalizedStatus);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT u.user_id, u.role_id, r.role_name, u.full_name, u.email, u.phone, u.password_hash, ")
                .append("u.address, u.status, u.created_at, u.google_sub, u.auth_provider, u.avatar_url, ")
                .append("u.email_verified, u.last_login_at, ISNULL(oc.order_count, 0) AS order_count ")
                .append("FROM users u ")
                .append("INNER JOIN roles r ON u.role_id = r.role_id ")
                .append("LEFT JOIN (SELECT user_id, COUNT(*) AS order_count FROM orders GROUP BY user_id) oc ON u.user_id = oc.user_id ")
                .append("WHERE r.role_name = 'customer' ");

        if (activeOnly) {
            sql.append("AND u.status = 1 ");
        } else if (inactiveOnly) {
            sql.append("AND u.status = 0 ");
        }
        if (hasKeyword) {
            sql.append("AND (u.email LIKE ? OR u.phone LIKE ? OR u.full_name LIKE ?) ");
        }
        sql.append("ORDER BY u.created_at DESC, u.user_id DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) {
                String like = "%" + normalizedKeyword + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return users;
    }

    public boolean updateUserStatus(int userId, boolean status) {
        if (userId <= 0) {
            return false;
        }

        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(String fullName, String email, String phone, String password) {
        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return false;
        }

        if (isEmailExists(email)) {
            return false;
        }

        int customerRoleId = getRoleIdByName("customer");
        String phoneValue = phone == null ? null : (phone.trim().isEmpty() ? null : phone.trim());

        String sql = "INSERT INTO users (role_id, full_name, email, phone, password_hash, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, 1, GETDATE())";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerRoleId);
            ps.setString(2, fullName.trim());
            ps.setString(3, email.trim());
            if (phoneValue != null) {
                ps.setString(4, phoneValue);
            } else {
                ps.setNull(4, java.sql.Types.VARCHAR);
            }
            ps.setString(5, password.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private int getRoleIdByName(String roleName) {
        String sql = "SELECT TOP 1 role_id FROM roles WHERE role_name = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("role_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 2;
    }

    private boolean verifyPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) {
            return false;
        }

        String raw = rawPassword.trim();
        String stored = storedPassword.trim();
        if (stored.isEmpty()) {
            return false;
        }

        if (stored.equals(raw)) {
            return true;
        }
        if (stored.equals("plain:" + raw)) {
            return true;
        }
        if (stored.equals("hashed_" + raw)) {
            return true;
        }

        String sha256 = sha256(raw);
        if (sha256 != null && (stored.equalsIgnoreCase(sha256) || stored.equalsIgnoreCase("sha256:" + sha256))) {
            return true;
        }

        return false;
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setRoleId(rs.getInt("role_id"));
        user.setRoleName(rs.getString("role_name"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setAddress(rs.getString("address"));
        user.setStatus(rs.getBoolean("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setGoogleSub(rs.getString("google_sub"));
        user.setAuthProvider(rs.getString("auth_provider"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setEmailVerified(rs.getBoolean("email_verified"));
        user.setLastLoginAt(rs.getTimestamp("last_login_at"));
        user.setOrderCount(readOrderCount(rs));
        return user;
    }

    private String normalizeNullable(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private int readOrderCount(ResultSet rs) {
        try {
            return rs.getInt("order_count");
        } catch (SQLException ex) {
            return 0;
        }
    }
}
