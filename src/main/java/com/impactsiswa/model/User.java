package com.impactsiswa.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class User {
    private int userId;
    private String fullName;
    private String matricNo;
    private String email;
    private String phone;
    private String faculty;
    private String role;
    private String passwordHash;
    private BigDecimal totalHours = BigDecimal.ZERO;
    private Timestamp createdAt;

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getMatricNo() { return matricNo; }
    public void setMatricNo(String matricNo) { this.matricNo = matricNo; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public BigDecimal getTotalHours() { return totalHours; }
    public void setTotalHours(BigDecimal totalHours) { this.totalHours = totalHours; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isStudent() { return "student".equals(role); }
    public boolean isClubLeader() { return "club_leader".equals(role); }
    public boolean isAdmin() { return "admin".equals(role); }

    public String getRoleLabel() {
        return switch (role) {
            case "admin" -> "Admin";
            case "club_leader" -> "Club Leader";
            default -> "Student";
        };
    }

    public String getBadgeName() {
        double hours = totalHours == null ? 0 : totalHours.doubleValue();
        if (hours >= 100) return "Platinum";
        if (hours >= 70) return "Gold";
        if (hours >= 35) return "Silver";
        return "Bronze";
    }

    public String getInitials() {
        if (fullName == null || fullName.isBlank()) {
            return "IS";
        }
        String[] parts = fullName.trim().split("\\s+");
        String first = parts[0].substring(0, 1);
        String second = parts.length > 1 ? parts[1].substring(0, 1) : "";
        return (first + second).toUpperCase();
    }
}
