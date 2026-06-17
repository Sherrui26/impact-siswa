package com.impactsiswa.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {
    private static final String URL = System.getenv().getOrDefault(
            "IMPACT_DB_URL",
            "jdbc:mysql://localhost:3306/impact_siswa?useSSL=false&serverTimezone=Asia/Kuala_Lumpur");
    private static final String USER = System.getenv().getOrDefault("IMPACT_DB_USER", "root");
    private static final String PASS = System.getenv().getOrDefault("IMPACT_DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL JDBC Driver not found", e);
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        // Centralized connection settings keep the DAO classes simple and make deployment changes safer.
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
