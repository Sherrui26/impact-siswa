package com.impactsiswa.model;

import java.math.BigDecimal;

public class DashboardStats {
    private BigDecimal totalUniversityHours = BigDecimal.ZERO;
    private int openEvents;
    private int pendingApprovals;
    private int approvedLogs;
    private int registeredStudents;

    public BigDecimal getTotalUniversityHours() { return totalUniversityHours; }
    public void setTotalUniversityHours(BigDecimal totalUniversityHours) { this.totalUniversityHours = totalUniversityHours; }
    public int getOpenEvents() { return openEvents; }
    public void setOpenEvents(int openEvents) { this.openEvents = openEvents; }
    public int getPendingApprovals() { return pendingApprovals; }
    public void setPendingApprovals(int pendingApprovals) { this.pendingApprovals = pendingApprovals; }
    public int getApprovedLogs() { return approvedLogs; }
    public void setApprovedLogs(int approvedLogs) { this.approvedLogs = approvedLogs; }
    public int getRegisteredStudents() { return registeredStudents; }
    public void setRegisteredStudents(int registeredStudents) { this.registeredStudents = registeredStudents; }
}
