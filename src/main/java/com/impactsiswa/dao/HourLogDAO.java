package com.impactsiswa.dao;

import com.impactsiswa.db.DBConnection;
import com.impactsiswa.model.User;
import com.impactsiswa.model.HourLog;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class HourLogDAO {
    public List<HourLog> findByUser(int userId) {
        return query("""
                SELECT hl.*, s.full_name AS student_name, s.matric_no, s.faculty,
                       e.title AS event_title, c.name AS category_name, a.full_name AS approver_name
                FROM hour_logs hl
                JOIN users s ON s.user_id = hl.user_id
                JOIN events e ON e.event_id = hl.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                LEFT JOIN users a ON a.user_id = hl.approved_by
                WHERE hl.user_id = ?
                ORDER BY hl.submitted_at DESC
                """, userId);
    }

    public List<HourLog> findPending() {
        return query("""
                SELECT hl.*, s.full_name AS student_name, s.matric_no, s.faculty,
                       e.title AS event_title, c.name AS category_name, a.full_name AS approver_name
                FROM hour_logs hl
                JOIN users s ON s.user_id = hl.user_id
                JOIN events e ON e.event_id = hl.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                LEFT JOIN users a ON a.user_id = hl.approved_by
                WHERE hl.status = 'pending'
                ORDER BY hl.submitted_at ASC
                """);
    }

    public List<HourLog> findPendingForReviewer(User reviewer) {
        String sql = """
                SELECT hl.*, s.full_name AS student_name, s.matric_no, s.faculty,
                       e.title AS event_title, c.name AS category_name, a.full_name AS approver_name
                FROM hour_logs hl
                JOIN users s ON s.user_id = hl.user_id
                JOIN events e ON e.event_id = hl.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                LEFT JOIN users a ON a.user_id = hl.approved_by
                WHERE hl.status = 'pending'
                """;
        if (!reviewer.isAdmin()) {
            sql += " AND e.created_by = ?\n";
        }
        sql += " ORDER BY hl.submitted_at ASC";
        return reviewer.isAdmin() ? query(sql) : query(sql, reviewer.getUserId());
    }

    public List<HourLog> findRecent(int limit) {
        List<HourLog> logs = new ArrayList<>();
        String sql = """
                SELECT hl.*, s.full_name AS student_name, s.matric_no, s.faculty,
                       e.title AS event_title, c.name AS category_name, a.full_name AS approver_name
                FROM hour_logs hl
                JOIN users s ON s.user_id = hl.user_id
                JOIN events e ON e.event_id = hl.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                LEFT JOIN users a ON a.user_id = hl.approved_by
                ORDER BY hl.submitted_at DESC
                LIMIT ?
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(map(rs));
                }
            }
            return logs;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list recent logs", e);
        }
    }

    public void create(int userId, int eventId, BigDecimal hours, String evidence, String proofImage) {
        String sql = """
                INSERT INTO hour_logs (user_id, event_id, hours_claimed, evidence, proof_image, status, remarks)
                VALUES (?, ?, ?, ?, ?, 'pending', 'Submitted for verification.')
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.setBigDecimal(3, hours);
            ps.setString(4, evidence);
            ps.setString(5, proofImage);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to submit hour claim", e);
        }
    }

    public boolean hasPendingOrApprovedClaim(int userId, int eventId) {
        String sql = """
                SELECT COUNT(*)
                FROM hour_logs
                WHERE user_id = ?
                  AND event_id = ?
                  AND status IN ('pending', 'approved')
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to check existing hour claim", e);
        }
    }

    public void cancelPending(int logId, int userId) {
        String sql = "DELETE FROM hour_logs WHERE log_id = ? AND user_id = ? AND status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, logId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to cancel hour claim", e);
        }
    }

    public void decide(int logId, int approverId, String status, String remarks) {
        String findSql = "SELECT user_id, hours_claimed, status FROM hour_logs WHERE log_id = ? FOR UPDATE";
        String updateLogSql = """
                UPDATE hour_logs
                SET status = ?, remarks = ?, approved_by = ?, approved_at = CURRENT_TIMESTAMP
                WHERE log_id = ?
                """;
        String updateHoursSql = "UPDATE users SET total_hours = total_hours + ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement find = conn.prepareStatement(findSql)) {
                find.setInt(1, logId);
                try (ResultSet rs = find.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return;
                    }
                    String previousStatus = rs.getString("status");
                    int studentId = rs.getInt("user_id");
                    BigDecimal hours = rs.getBigDecimal("hours_claimed");

                    try (PreparedStatement updateLog = conn.prepareStatement(updateLogSql)) {
                        updateLog.setString(1, status);
                        updateLog.setString(2, remarks);
                        updateLog.setInt(3, approverId);
                        updateLog.setInt(4, logId);
                        updateLog.executeUpdate();
                    }

                    // The transaction keeps approval status and accumulated hours synchronized.
                    if ("approved".equals(status) && !"approved".equals(previousStatus)) {
                        try (PreparedStatement updateHours = conn.prepareStatement(updateHoursSql)) {
                            updateHours.setBigDecimal(1, hours);
                            updateHours.setInt(2, studentId);
                            updateHours.executeUpdate();
                        }
                    }
                    conn.commit();
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to update approval decision", e);
        }
    }

    private List<HourLog> query(String sql, Object... params) {
        List<HourLog> logs = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(map(rs));
                }
            }
            return logs;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list hour logs", e);
        }
    }

    private HourLog map(ResultSet rs) throws SQLException {
        HourLog log = new HourLog();
        log.setLogId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setStudentName(rs.getString("student_name"));
        log.setMatricNo(rs.getString("matric_no"));
        log.setFaculty(rs.getString("faculty"));
        log.setEventId(rs.getInt("event_id"));
        log.setEventTitle(rs.getString("event_title"));
        log.setCategoryName(rs.getString("category_name"));
        log.setHoursClaimed(rs.getBigDecimal("hours_claimed"));
        log.setEvidence(rs.getString("evidence"));
        log.setProofImage(rs.getString("proof_image"));
        log.setStatus(rs.getString("status"));
        log.setRemarks(rs.getString("remarks"));
        int approvedBy = rs.getInt("approved_by");
        log.setApprovedBy(rs.wasNull() ? null : approvedBy);
        log.setApproverName(rs.getString("approver_name"));
        log.setSubmittedAt(rs.getTimestamp("submitted_at"));
        log.setApprovedAt(rs.getTimestamp("approved_at"));
        return log;
    }
}
