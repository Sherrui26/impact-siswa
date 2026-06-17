package com.impactsiswa.model;

import java.sql.Timestamp;

public class Affiliation {
    private int affiliationId;
    private String name;
    private String type;
    private boolean active;
    private Timestamp createdAt;

    public int getAffiliationId() { return affiliationId; }
    public void setAffiliationId(int affiliationId) { this.affiliationId = affiliationId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getTypeLabel() {
        return switch (type) {
            case "club" -> "Club";
            case "unit" -> "University Unit";
            default -> "Faculty";
        };
    }
}
