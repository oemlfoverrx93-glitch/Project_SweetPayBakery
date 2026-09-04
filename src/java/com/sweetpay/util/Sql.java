package com.sweetpay.util;

import java.sql.*;
import java.util.*;

/** Small JDBC helper. Callers own the connection and transaction. */
public final class Sql {
    private Sql() { }
    public static PreparedStatement prepare(Connection c, String sql, Object... args) throws SQLException {
        PreparedStatement p = c.prepareStatement(sql);
        try {
            for (int i = 0; i < args.length; i++) p.setObject(i + 1, args[i]);
            return p;
        } catch (SQLException e) { p.close(); throw e; }
    }
    public static int update(Connection c, String sql, Object... args) throws SQLException {
        try (PreparedStatement p = prepare(c, sql, args)) { return p.executeUpdate(); }
    }
    public static List<Map<String,Object>> rows(Connection c, String sql, Object... args) throws SQLException {
        List<Map<String,Object>> rows = new ArrayList<>();
        try (PreparedStatement p = prepare(c, sql, args); ResultSet r = p.executeQuery()) {
            ResultSetMetaData m = r.getMetaData();
            while (r.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                for (int i=1; i<=m.getColumnCount(); i++) row.put(m.getColumnLabel(i).toLowerCase(Locale.ROOT), r.getObject(i));
                rows.add(row);
            }
        }
        return rows;
    }
    public static Map<String,Object> one(Connection c, String sql, Object... args) throws SQLException {
        List<Map<String,Object>> rows = rows(c, sql, args);
        return rows.isEmpty() ? null : rows.get(0);
    }
    public static int number(Map<String,Object> row, String key) {
        Object v = row.get(key); return v instanceof Number ? ((Number)v).intValue() : 0;
    }
    public static String string(Map<String,Object> row, String key) {
        Object v = row.get(key); return v == null ? "" : String.valueOf(v);
    }
}
