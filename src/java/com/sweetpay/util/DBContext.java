package com.sweetpay.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DBContext {

    private static final String URL_BY_PORT = "jdbc:sqlserver://localhost:1433;databaseName=SweetPayBakery;encrypt=true;trustServerCertificate=true;loginTimeout=3;";
    private static final String URL_BY_INSTANCE = "jdbc:sqlserver://localhost;instanceName=MSSQLSERVER01;databaseName=SweetPayBakery;encrypt=true;trustServerCertificate=true;loginTimeout=3;";
    private static final String USER = "sa";
    private static final String PASSWORD = "123456";
    private static volatile boolean connectionInfoLogged;

    public static Connection getConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        List<String> urls = new ArrayList<>();
        addIfNotBlank(urls, System.getenv("SWEETPAY_DB_URL"));
        addIfNotBlank(urls, System.getProperty("sweetpay.db.url"));

        // Try by fixed port first to avoid named-instance lookup timeout when SQL Browser is disabled.
        urls.add(URL_BY_PORT);
        urls.add(URL_BY_INSTANCE);

        SQLException lastException = null;
        for (String url : urls) {
            try {
                Connection connection = DriverManager.getConnection(url, USER, PASSWORD);
                if (!connectionInfoLogged) {
                    System.out.println("[DBContext] Connected URL: " + url);
                    connectionInfoLogged = true;
                }
                return connection;
            } catch (SQLException ex) {
                lastException = ex;
            }
        }

        if (lastException != null) {
            throw lastException;
        }

        throw new SQLException("Cannot establish database connection.");
    }

    private static void addIfNotBlank(List<String> urls, String value) {
        if (value == null) {
            return;
        }
        String trimmed = value.trim();
        if (!trimmed.isEmpty()) {
            urls.add(trimmed);
        }
    }
}
