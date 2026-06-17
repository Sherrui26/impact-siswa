package com.impactsiswa.dao;

import com.impactsiswa.db.DBConnection;
import com.impactsiswa.model.DashboardStats;
import com.impactsiswa.model.LabelValue;
import com.impactsiswa.model.User;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {
    public DashboardStats dashboardStats() {
        return dashboardStats(null);
    }

    public DashboardStats dashboardStats(User user) {
        DashboardStats stats = new DashboardStats();
        try (Connection conn = DBConnection.getConnection()) {
            if (user != null && user.isClubLeader()) {
                stats.setTotalUniversityHours(singleDecimal(conn, """
                        SELECT COALESCE(SUM(hl.hours_claimed), 0)
                        FROM hour_logs hl
                        JOIN events e ON e.event_id = hl.event_id
                        WHERE hl.status = 'approved' AND e.created_by = ?
                        """, user.getUserId()));
                stats.setOpenEvents(singleInt(conn, "SELECT COUNT(*) FROM events WHERE status = 'open' AND created_by = ?", user.getUserId()));
                stats.setApprovedLogs(singleInt(conn, """
                        SELECT COUNT(*)
                        FROM hour_logs hl
                        JOIN events e ON e.event_id = hl.event_id
                        WHERE hl.status = 'approved' AND e.created_by = ?
                        """, user.getUserId()));
                stats.setRegisteredStudents(singleInt(conn, """
                        SELECT COUNT(DISTINCT er.user_id)
                        FROM event_registrations er
                        JOIN events e ON e.event_id = er.event_id
                        WHERE er.status = 'approved' AND e.created_by = ?
                        """, user.getUserId()));
            } else {
                stats.setTotalUniversityHours(singleDecimal(conn,
                        "SELECT COALESCE(SUM(hours_claimed), 0) FROM hour_logs WHERE status = 'approved'"));
                stats.setOpenEvents(singleInt(conn, "SELECT COUNT(*) FROM events WHERE status = 'open'"));
                stats.setApprovedLogs(singleInt(conn, "SELECT COUNT(*) FROM hour_logs WHERE status = 'approved'"));
                stats.setRegisteredStudents(singleInt(conn, "SELECT COUNT(*) FROM users WHERE role = 'student'"));
            }
            stats.setPendingApprovals(pendingApprovalsFor(conn, user));
            return stats;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to load dashboard stats", e);
        }
    }

    public List<LabelValue> hoursByFaculty() {
        return labelValues("""
                SELECT u.faculty AS label, COALESCE(SUM(hl.hours_claimed), 0) AS value
                FROM users u
                LEFT JOIN hour_logs hl ON hl.user_id = u.user_id AND hl.status = 'approved'
                WHERE u.role = 'student'
                GROUP BY u.faculty
                ORDER BY value DESC, label ASC
                """);
    }

    public List<LabelValue> topClubs() {
        return labelValues("""
                SELECT COALESCE(NULLIF(TRIM(creator.faculty), ''), creator.full_name) AS label,
                       COALESCE(SUM(hl.hours_claimed), 0) AS value
                FROM events e
                JOIN users creator ON creator.user_id = e.created_by
                LEFT JOIN hour_logs hl ON hl.event_id = e.event_id AND hl.status = 'approved'
                WHERE creator.role IN ('club_leader','admin')
                GROUP BY label
                ORDER BY value DESC, label ASC
                LIMIT 5
                """);
    }

    public List<LabelValue> monthlyTrend() {
        return labelValues("""
                SELECT DATE_FORMAT(submitted_at, '%b %Y') AS label, COALESCE(SUM(hours_claimed), 0) AS value
                FROM hour_logs
                WHERE status = 'approved'
                GROUP BY YEAR(submitted_at), MONTH(submitted_at), DATE_FORMAT(submitted_at, '%b %Y')
                ORDER BY YEAR(submitted_at), MONTH(submitted_at)
                LIMIT 6
                """);
    }

    private List<LabelValue> labelValues(String sql) {
        List<LabelValue> values = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                values.add(new LabelValue(rs.getString("label"), rs.getBigDecimal("value")));
            }
            return values;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to load report data", e);
        }
    }

    private int singleInt(Connection conn, String sql) throws SQLException {
        return singleInt(conn, sql, new Object[0]);
    }

    private int singleInt(Connection conn, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int pendingApprovalsFor(Connection conn, User user) throws SQLException {
        if (user == null || user.isAdmin()) {
            return singleInt(conn, """
                    SELECT
                        (SELECT COUNT(*) FROM hour_logs WHERE status = 'pending') +
                        (SELECT COUNT(*) FROM event_registrations WHERE status = 'pending')
                    """);
        }

        if (user.isClubLeader()) {
            return singleInt(conn, """
                    SELECT
                        (SELECT COUNT(*)
                         FROM hour_logs hl
                         JOIN events e ON e.event_id = hl.event_id
                         WHERE hl.status = 'pending' AND e.created_by = ?) +
                        (SELECT COUNT(*)
                         FROM event_registrations er
                         JOIN events e ON e.event_id = er.event_id
                         WHERE er.status = 'pending' AND e.created_by = ?)
                    """, user.getUserId(), user.getUserId());
        }

        return singleInt(conn, """
                SELECT
                    (SELECT COUNT(*) FROM hour_logs WHERE status = 'pending' AND user_id = ?) +
                    (SELECT COUNT(*) FROM event_registrations WHERE status = 'pending' AND user_id = ?)
                """, user.getUserId(), user.getUserId());
    }

    private BigDecimal singleDecimal(Connection conn, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }
}
