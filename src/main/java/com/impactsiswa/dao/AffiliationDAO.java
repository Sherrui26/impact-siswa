package com.impactsiswa.dao;

import com.impactsiswa.db.DBConnection;
import com.impactsiswa.model.Affiliation;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AffiliationDAO {
    public List<Affiliation> findAll() {
        return query("SELECT * FROM affiliations ORDER BY type, active DESC, name");
    }

    public List<Affiliation> findActive() {
        return query("SELECT * FROM affiliations WHERE active = TRUE ORDER BY type, name");
    }

    public List<Affiliation> findActiveByType(String type) {
        return query("SELECT * FROM affiliations WHERE active = TRUE AND type = ? ORDER BY name", type);
    }

    public Affiliation findById(int affiliationId) {
        List<Affiliation> results = query("SELECT * FROM affiliations WHERE affiliation_id = ?", affiliationId);
        return results.isEmpty() ? null : results.get(0);
    }

    public void save(Affiliation affiliation) {
        if (affiliation.getAffiliationId() > 0) {
            update(affiliation);
        } else {
            create(affiliation);
        }
    }

    public void delete(int affiliationId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM affiliations WHERE affiliation_id = ?")) {
            ps.setInt(1, affiliationId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to delete faculty or club", e);
        }
    }

    private void create(Affiliation affiliation) {
        String sql = "INSERT INTO affiliations (name, type, active) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setFields(ps, affiliation);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to create faculty or club", e);
        }
    }

    private void update(Affiliation affiliation) {
        String sql = "UPDATE affiliations SET name = ?, type = ?, active = ? WHERE affiliation_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setFields(ps, affiliation);
            ps.setInt(4, affiliation.getAffiliationId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to update faculty or club", e);
        }
    }

    private List<Affiliation> query(String sql, Object... params) {
        List<Affiliation> affiliations = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    affiliations.add(map(rs));
                }
            }
            return affiliations;
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to list faculties and clubs", e);
        }
    }

    private void setFields(PreparedStatement ps, Affiliation affiliation) throws SQLException {
        ps.setString(1, affiliation.getName());
        ps.setString(2, affiliation.getType());
        ps.setBoolean(3, affiliation.isActive());
    }

    private Affiliation map(ResultSet rs) throws SQLException {
        Affiliation affiliation = new Affiliation();
        affiliation.setAffiliationId(rs.getInt("affiliation_id"));
        affiliation.setName(rs.getString("name"));
        affiliation.setType(rs.getString("type"));
        affiliation.setActive(rs.getBoolean("active"));
        affiliation.setCreatedAt(rs.getTimestamp("created_at"));
        return affiliation;
    }
}
