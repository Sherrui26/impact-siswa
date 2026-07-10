package com.impactsiswa.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class VolunteerEvent {
    private int eventId;
    private String title;
    private String description;
    private int catId;
    private String categoryName;
    private Date eventDate;
    private String location;
    private BigDecimal hours;
    private String imagePath;
    private int maxVolunteers;
    private int joinedCount;
    private boolean joinedByCurrentUser;
    private String registrationStatus;
    private String status;
    private int createdBy;
    private String creatorName;
    private Timestamp createdAt;
    private BigDecimal claimedHours;
    private String claimStatus;

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getCatId() { return catId; }
    public void setCatId(int catId) { this.catId = catId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public BigDecimal getHours() { return hours; }
    public void setHours(BigDecimal hours) { this.hours = hours; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public boolean isHasImage() { return imagePath != null && !imagePath.isBlank(); }
    public int getMaxVolunteers() { return maxVolunteers; }
    public void setMaxVolunteers(int maxVolunteers) { this.maxVolunteers = maxVolunteers; }
    public int getJoinedCount() { return joinedCount; }
    public void setJoinedCount(int joinedCount) { this.joinedCount = joinedCount; }
    public boolean isJoinedByCurrentUser() { return joinedByCurrentUser; }
    public void setJoinedByCurrentUser(boolean joinedByCurrentUser) { this.joinedByCurrentUser = joinedByCurrentUser; }
    public String getRegistrationStatus() { return registrationStatus; }
    public void setRegistrationStatus(String registrationStatus) { this.registrationStatus = registrationStatus; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public BigDecimal getClaimedHours() { return claimedHours; }
    public void setClaimedHours(BigDecimal claimedHours) { this.claimedHours = claimedHours; }
    public String getClaimStatus() { return claimStatus; }
    public void setClaimStatus(String claimStatus) { this.claimStatus = claimStatus; }

    public boolean isClaimed() {
        return claimedHours != null;
    }

    public int getSlotsLeft() {
        return Math.max(0, maxVolunteers - joinedCount);
    }
}
