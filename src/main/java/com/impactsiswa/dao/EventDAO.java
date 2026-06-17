package com.impactsiswa.dao;

import com.impactsiswa.db.DBConnection;
import com.impactsiswa.model.EventRegistration;
import com.impactsiswa.model.User;
import com.impactsiswa.model.VolunteerEvent;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
    public List<VolunteerEvent> findAll(int currentUserId) {
        List<VolunteerEvent> events = new ArrayList<>();
        String sql = """
                SELECT e.*, c.name AS category_name, u.full_name AS creator_name,
                       COALESCE(joined.total, 0) AS joined_count,
                       CASE WHEN mine.status = 'approved' THEN 1 ELSE 0 END AS joined_by_current_user,
                       mine.status AS registration_status
                FROM events e
                JOIN categories c ON c.cat_id = e.cat_id
                JOIN users u ON u.user_id = e.created_by
                LEFT JOIN (
                    SELECT event_id, COUNT(*) AS total
                    FROM event_registrations
                    WHERE status = 'approved'
                    GROUP BY event_id
                ) joined ON joined.event_id = e.event_id
                LEFT JOIN event_registrations mine
                    ON mine.event_id = e.event_id AND mine.user_id = ?
                ORDER BY e.event_date ASC, e.title ASC
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    events.add(map(rs));
                }
            }
            return events;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list events", e);
        }
    }

    public VolunteerEvent findById(int eventId) {
        String sql = """
                SELECT e.*, c.name AS category_name, u.full_name AS creator_name,
                       COALESCE(joined.total, 0) AS joined_count,
                       0 AS joined_by_current_user,
                       NULL AS registration_status
                FROM events e
                JOIN categories c ON c.cat_id = e.cat_id
                JOIN users u ON u.user_id = e.created_by
                LEFT JOIN (
                    SELECT event_id, COUNT(*) AS total
                    FROM event_registrations
                    WHERE status = 'approved'
                    GROUP BY event_id
                ) joined ON joined.event_id = e.event_id
                WHERE e.event_id = ?
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to find event", e);
        }
    }

    public void create(VolunteerEvent event) {
        String sql = """
                INSERT INTO events (title, description, cat_id, event_date, location, hours, max_volunteers, status, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            fillEventStatement(ps, event);
            ps.setInt(9, event.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    event.setEventId(keys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to create event", e);
        }
    }

    public void update(VolunteerEvent event) {
        String sql = """
                UPDATE events
                SET title = ?, description = ?, cat_id = ?, event_date = ?, location = ?, hours = ?, max_volunteers = ?, status = ?
                WHERE event_id = ?
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            fillEventStatement(ps, event);
            ps.setInt(9, event.getEventId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to update event", e);
        }
    }

    public void delete(int eventId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM events WHERE event_id = ?")) {
            ps.setInt(1, eventId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to delete event", e);
        }
    }

    public List<VolunteerEvent> findApprovedForClaim(int userId) {
        List<VolunteerEvent> events = new ArrayList<>();
        String sql = """
                SELECT e.*, c.name AS category_name, u.full_name AS creator_name,
                       COALESCE(joined.total, 0) AS joined_count,
                       1 AS joined_by_current_user,
                       er.status AS registration_status
                FROM event_registrations er
                JOIN events e ON e.event_id = er.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                JOIN users u ON u.user_id = e.created_by
                LEFT JOIN (
                    SELECT event_id, COUNT(*) AS total
                    FROM event_registrations
                    WHERE status = 'approved'
                    GROUP BY event_id
                ) joined ON joined.event_id = e.event_id
                WHERE er.user_id = ? AND er.status = 'approved'
                  AND NOT EXISTS (
                      SELECT 1
                      FROM hour_logs hl
                      WHERE hl.user_id = er.user_id
                        AND hl.event_id = er.event_id
                        AND hl.status IN ('pending', 'approved')
                  )
                ORDER BY e.event_date DESC, e.title ASC
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    events.add(map(rs));
                }
            }
            return events;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list approved joined events", e);
        }
    }

    public List<EventRegistration> findPendingRegistrations(User reviewer) {
        List<EventRegistration> requests = new ArrayList<>();
        String sql = """
                SELECT er.*, s.full_name AS student_name, s.matric_no, s.faculty,
                       e.title AS event_title, e.event_date, e.location, e.hours, c.name AS category_name
                FROM event_registrations er
                JOIN users s ON s.user_id = er.user_id
                JOIN events e ON e.event_id = er.event_id
                JOIN categories c ON c.cat_id = e.cat_id
                WHERE er.status = 'pending'
                """;
        if (!reviewer.isAdmin()) {
            sql += " AND e.created_by = ?\n";
        }
        sql += " ORDER BY er.registered_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (!reviewer.isAdmin()) {
                ps.setInt(1, reviewer.getUserId());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRegistration(rs));
                }
            }
            return requests;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list event registration requests", e);
        }
    }

    public void decideRegistration(int registrationId, User reviewer, String status) {
        String sql = """
                UPDATE event_registrations er
                JOIN events e ON e.event_id = er.event_id
                SET er.status = ?
                WHERE er.registration_id = ? AND er.status = 'pending'
                """;
        if (!reviewer.isAdmin()) {
            sql += " AND e.created_by = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, registrationId);
            if (!reviewer.isAdmin()) {
                ps.setInt(3, reviewer.getUserId());
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to update event registration request", e);
        }
    }

    public int approveAllPendingRegistrations(User reviewer) {
        String sql = """
                UPDATE event_registrations er
                JOIN events e ON e.event_id = er.event_id
                SET er.status = 'approved'
                WHERE er.status = 'pending'
                """;
        if (!reviewer.isAdmin()) {
            sql += " AND e.created_by = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (!reviewer.isAdmin()) {
                ps.setInt(1, reviewer.getUserId());
            }
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to approve all event registration requests", e);
        }
    }

    public boolean hasApprovedRegistration(int eventId, int userId) {
        String sql = """
                SELECT COUNT(*)
                FROM event_registrations
                WHERE event_id = ? AND user_id = ? AND status = 'approved'
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to verify approved event registration", e);
        }
    }

    public void joinEvent(int eventId, int userId) {
        String sql = """
                INSERT INTO event_registrations (event_id, user_id, status)
                VALUES (?, ?, 'pending')
                ON DUPLICATE KEY UPDATE status = 'pending', registered_at = CURRENT_TIMESTAMP
                """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to join event", e);
        }
    }

    public void cancelJoin(int eventId, int userId) {
        String sql = "UPDATE event_registrations SET status = 'cancelled' WHERE event_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to cancel registration", e);
        }
    }

    private void fillEventStatement(PreparedStatement ps, VolunteerEvent event) throws SQLException {
        ps.setString(1, event.getTitle());
        ps.setString(2, event.getDescription());
        ps.setInt(3, event.getCatId());
        ps.setDate(4, event.getEventDate());
        ps.setString(5, event.getLocation());
        ps.setBigDecimal(6, event.getHours());
        ps.setInt(7, event.getMaxVolunteers());
        ps.setString(8, event.getStatus());
    }

    private VolunteerEvent map(ResultSet rs) throws SQLException {
        VolunteerEvent event = new VolunteerEvent();
        event.setEventId(rs.getInt("event_id"));
        event.setTitle(rs.getString("title"));
        event.setDescription(rs.getString("description"));
        event.setCatId(rs.getInt("cat_id"));
        event.setCategoryName(rs.getString("category_name"));
        event.setEventDate(Date.valueOf(rs.getDate("event_date").toLocalDate()));
        event.setLocation(rs.getString("location"));
        event.setHours(rs.getBigDecimal("hours"));
        event.setMaxVolunteers(rs.getInt("max_volunteers"));
        event.setJoinedCount(rs.getInt("joined_count"));
        event.setJoinedByCurrentUser(rs.getInt("joined_by_current_user") == 1);
        event.setRegistrationStatus(rs.getString("registration_status"));
        event.setStatus(rs.getString("status"));
        event.setCreatedBy(rs.getInt("created_by"));
        event.setCreatorName(rs.getString("creator_name"));
        event.setCreatedAt(rs.getTimestamp("created_at"));
        return event;
    }

    private EventRegistration mapRegistration(ResultSet rs) throws SQLException {
        EventRegistration registration = new EventRegistration();
        registration.setRegistrationId(rs.getInt("registration_id"));
        registration.setEventId(rs.getInt("event_id"));
        registration.setUserId(rs.getInt("user_id"));
        registration.setStudentName(rs.getString("student_name"));
        registration.setMatricNo(rs.getString("matric_no"));
        registration.setFaculty(rs.getString("faculty"));
        registration.setEventTitle(rs.getString("event_title"));
        registration.setCategoryName(rs.getString("category_name"));
        registration.setEventDate(Date.valueOf(rs.getDate("event_date").toLocalDate()));
        registration.setLocation(rs.getString("location"));
        registration.setHours(rs.getBigDecimal("hours"));
        registration.setStatus(rs.getString("status"));
        registration.setRegisteredAt(rs.getTimestamp("registered_at"));
        return registration;
    }
}
