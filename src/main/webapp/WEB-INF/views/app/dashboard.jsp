<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard" />
<%@ include file="../includes/layout-start.jspf" %>
<c:choose>
    <c:when test="${sessionScope.currentUser.badgeName eq 'Platinum'}"><c:set var="dashboardBadgeImage" value="${ctx}/images/platinum.png" /></c:when>
    <c:when test="${sessionScope.currentUser.badgeName eq 'Gold'}"><c:set var="dashboardBadgeImage" value="${ctx}/images/gold.png" /></c:when>
    <c:when test="${sessionScope.currentUser.badgeName eq 'Silver'}"><c:set var="dashboardBadgeImage" value="${ctx}/images/silver.png" /></c:when>
    <c:otherwise><c:set var="dashboardBadgeImage" value="${ctx}/images/bronze.png" /></c:otherwise>
</c:choose>

<div class="page-heading">
    <div>
        <h1>${sessionScope.currentUser.roleLabel} Dashboard</h1>
        <c:choose>
            <c:when test="${sessionScope.currentUser.role eq 'student'}">
                <p>Overview of your volunteer hours, event requests, approvals, and university impact.</p>
            </c:when>
            <c:when test="${sessionScope.currentUser.role eq 'club_leader'}">
                <p>Overview of your managed events, student requests, verified claims, and club impact.</p>
            </c:when>
            <c:otherwise>
                <p>University-wide overview of volunteer activity, student participation, approvals, and events.</p>
            </c:otherwise>
        </c:choose>
    </div>
        <c:if test="${sessionScope.currentUser.role eq 'student'}">
    <div class="achievement-chip">
        <img src="${dashboardBadgeImage}" alt="${sessionScope.currentUser.badgeName} badge">
        <div>
            <span>Achievement</span>
            <strong>${sessionScope.currentUser.badgeName} Badge</strong>
            <em>${sessionScope.currentUser.totalHours} verified hours</em>
        </div>
        <button type="button" class="badge-info-btn" id="badgeInfoBtn" aria-label="How badges work" title="How badges work"><i class="bi bi-info-circle"></i></button>
    </div>
    </c:if>
</div>

<c:if test="${sessionScope.currentUser.role eq 'student'}">
<div class="modal-backdrop" id="badgeInfoModal" hidden>
    <div class="detail-dialog badge-info-dialog" role="dialog" aria-modal="true" aria-labelledby="badgeInfoTitle">
        <div class="detail-header">
            <div>
                <p class="confirm-kicker">Achievement badges</p>
                <h2 id="badgeInfoTitle">Climb the ranks by volunteering</h2>
            </div>
            <button class="icon-btn" type="button" data-badge-info-close aria-label="Close"><i class="bi bi-x-lg"></i></button>
        </div>
        <p class="muted">Every hour you complete and get verified counts toward your badge. The more you volunteer, the higher you climb. Here are the tiers:</p>
                <div class="badge-tier-list">
            <div class="badge-tier ${sessionScope.currentUser.badgeName eq 'Platinum' ? 'is-current' : ''}">
                <img src="${ctx}/images/platinum.png" alt="Platinum badge">
                <div><strong>Platinum</strong><span>100+ hours</span></div>
                <c:if test="${sessionScope.currentUser.badgeName eq 'Platinum'}"><span class="pill green">You are here</span></c:if>
            </div>
            <div class="badge-tier ${sessionScope.currentUser.badgeName eq 'Gold' ? 'is-current' : ''}">
                <img src="${ctx}/images/gold.png" alt="Gold badge">
                <div><strong>Gold</strong><span>70 - 99 hours</span></div>
                <c:if test="${sessionScope.currentUser.badgeName eq 'Gold'}"><span class="pill green">You are here</span></c:if>
            </div>
            <div class="badge-tier ${sessionScope.currentUser.badgeName eq 'Silver' ? 'is-current' : ''}">
                <img src="${ctx}/images/silver.png" alt="Silver badge">
                <div><strong>Silver</strong><span>35 - 69 hours</span></div>
                <c:if test="${sessionScope.currentUser.badgeName eq 'Silver'}"><span class="pill green">You are here</span></c:if>
            </div>
            <div class="badge-tier ${sessionScope.currentUser.badgeName eq 'Bronze' ? 'is-current' : ''}">
                <img src="${ctx}/images/bronze.png" alt="Bronze badge">
                <div><strong>Bronze</strong><span>0 - 34 hours</span></div>
                <c:if test="${sessionScope.currentUser.badgeName eq 'Bronze'}"><span class="pill green">You are here</span></c:if>
            </div>
        </div>
        <div class="detail-section badge-next-step">
            <c:choose>
                <c:when test="${sessionScope.currentUser.badgeName eq 'Bronze'}">
                    <h3>Next stop: Silver</h3>
                    <p class="muted">Reach 35 verified hours to earn your Silver badge. Join more events to get there.</p>
                </c:when>
                <c:when test="${sessionScope.currentUser.badgeName eq 'Silver'}">
                    <h3>Next stop: Gold</h3>
                    <p class="muted">Reach 70 verified hours to earn your Gold badge. Keep volunteering.</p>
                </c:when>
                <c:when test="${sessionScope.currentUser.badgeName eq 'Gold'}">
                    <h3>Next stop: Platinum</h3>
                    <p class="muted">Reach 100 verified hours to earn the top Platinum badge. You are almost there.</p>
                </c:when>
                <c:otherwise>
                    <h3>You have reached the top</h3>
                    <p class="muted">Platinum is the highest badge. Keep volunteering to grow your impact even further.</p>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="confirm-actions">
            <a class="btn success" href="${ctx}/app/events"><i class="bi bi-calendar-check"></i>Browse Events to Join</a>
        </div>
    </div>
</div>
</c:if>

<div class="grid stats-grid">
    <c:choose>
        <c:when test="${sessionScope.currentUser.role eq 'student'}">
            <div class="stat-card"><span>My Total Hours</span><strong>${sessionScope.currentUser.totalHours}</strong><em>${sessionScope.currentUser.badgeName} social credit</em></div>
            <div class="stat-card"><span>Open Events</span><strong>${stats.openEvents}</strong><em>Available opportunities</em></div>
            <div class="stat-card"><span>University Impact</span><strong>${stats.totalUniversityHours}</strong><em>Approved volunteer hours</em></div>
        </c:when>
        <c:when test="${sessionScope.currentUser.role eq 'club_leader'}">
            <div class="stat-card"><span>Club Impact</span><strong>${stats.totalUniversityHours}</strong><em>Approved hours from your events</em></div>
            <div class="stat-card"><span>My Open Events</span><strong>${stats.openEvents}</strong><em>Opportunities you manage</em></div>
            <div class="stat-card"><span>Verified Claims</span><strong>${stats.approvedLogs}</strong><em>Approved student submissions</em></div>
        </c:when>
        <c:otherwise>
            <div class="stat-card"><span>Total Approved Hours</span><strong>${stats.totalUniversityHours}</strong><em>University volunteer impact</em></div>
            <div class="stat-card"><span>Open Events</span><strong>${stats.openEvents}</strong><em>Active opportunities</em></div>
            <div class="stat-card"><span>Registered Students</span><strong>${stats.registeredStudents}</strong><em>Student accounts</em></div>
        </c:otherwise>
    </c:choose>
    <div class="stat-card attention-card">
        <c:if test="${stats.pendingApprovals gt 0}">
            <span class="attention-dot" aria-label="Pending items need attention"></span>
        </c:if>
        <span>Pending Approvals</span><strong>${stats.pendingApprovals}</strong><em>Waiting for review</em>
    </div>
</div>

<c:if test="${sessionScope.currentUser.role ne 'student'}">
    <div class="panel approval-action-panel">
        <div class="section-title approval-action-header">
            <div>
                <h2>Pending Approval Summary</h2>
                <p class="panel-subtitle">Join requests and hour claims that need your review.</p>
            </div>
            <div class="table-actions">
                <span class="pill ${stats.pendingApprovals gt 0 ? 'red' : 'green'}">${stats.pendingApprovals} waiting</span>
                <a class="btn success" href="${ctx}/app/approvals"><i class="bi bi-check2-square"></i>Review Approvals</a>
            </div>
        </div>
        <div class="approval-preview-grid">
            <c:choose>
                <c:when test="${empty pendingRegistrations && empty pendingLogs}">
                    <div class="empty-state compact-empty"><strong>All caught up.</strong><p class="muted">There are no approval items waiting for your action.</p></div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="request" items="${pendingRegistrations}" varStatus="loop">
                        <c:if test="${loop.index lt 3}">
                            <article class="event-card">
                                <h3><c:out value="${request.studentName}"/></h3>
                                <div class="event-meta">
                                    <span class="pill amber">join request</span>
                                    <span class="pill"><c:out value="${request.eventTitle}"/></span>
                                </div>
                            </article>
                        </c:if>
                    </c:forEach>
                    <c:forEach var="log" items="${pendingLogs}" varStatus="loop">
                        <c:if test="${empty pendingRegistrations && loop.index lt 3}">
                            <article class="event-card">
                                <h3><c:out value="${log.studentName}"/></h3>
                                <div class="event-meta">
                                    <span class="pill amber">${log.hoursClaimed} hours</span>
                                    <span class="pill"><c:out value="${log.eventTitle}"/></span>
                                </div>
                            </article>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</c:if>

<c:choose>
    <c:when test="${sessionScope.currentUser.role eq 'student'}">
        <div class="grid dash-grid" style="margin-top:18px;">
            <div class="grid">
                <div class="panel chart-box">
                    <h2>Hours by Faculty</h2>
                    <p class="panel-subtitle">Approved volunteer hours grouped by faculty.</p>
                    <canvas id="facultyChart"></canvas>
                </div>
                <div class="panel chart-box">
                    <h2>Monthly Hours Trend</h2>
                    <p class="panel-subtitle">Approved hours grouped by submission month.</p>
                    <canvas id="monthlyChart"></canvas>
                </div>
            </div>
            <div class="grid">
                <div class="panel chart-box">
                    <h2>Top 5 Organizers/Clubs</h2>
                    <p class="panel-subtitle">Approved volunteer hours by club or university unit.</p>
                    <canvas id="clubChart"></canvas>
                </div>
                                <div class="panel">
                    <div class="section-title" style="margin-bottom:14px;">
                        <div>
                            <h2>Upcoming Events</h2>
                            <p class="panel-subtitle" style="margin-bottom:0;">Events you can request to join next.</p>
                        </div>
                        <a class="btn" href="${ctx}/app/events"><i class="bi bi-arrow-right"></i>See all</a>
                    </div>
                    <div class="upcoming-list">
                        <c:forEach var="event" items="${events}" varStatus="loop">
                            <c:if test="${loop.index lt 3}">
                                <a class="upcoming-item" href="${ctx}/app/events">
                                    <span class="upcoming-date">
                                        <strong><fmt:formatDate value="${event.eventDate}" pattern="dd"/></strong>
                                        <span><fmt:formatDate value="${event.eventDate}" pattern="MMM"/></span>
                                    </span>
                                    <span class="upcoming-body">
                                        <strong><c:out value="${event.title}"/></strong>
                                        <span class="upcoming-meta">
                                            <span><i class="bi bi-geo-alt"></i><c:out value="${event.location}"/></span>
                                            <span><i class="bi bi-clock"></i>${event.hours} hours</span>
                                        </span>
                                    </span>
                                    <span class="pill"><c:out value="${event.categoryName}"/></span>
                                </a>
                            </c:if>
                        </c:forEach>
                        <c:if test="${empty events}">
                            <div class="empty-state"><strong>No upcoming events.</strong><p class="muted">Check back soon for new opportunities.</p></div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </c:when>
        <c:otherwise>
        <div class="grid report-grid" style="margin-top:18px;">
            <div class="panel chart-box">
                <h2>Hours by Faculty</h2>
                <p class="panel-subtitle">Approved volunteer hours grouped by faculty.</p>
                <canvas id="facultyChart"></canvas>
            </div>
            <div class="panel chart-box">
                <h2>Monthly Hours Trend</h2>
                <p class="panel-subtitle">Approved hours grouped by submission month.</p>
                <canvas id="monthlyChart"></canvas>
            </div>
            <div class="panel chart-box">
                <h2>Top 5 Organizers/Clubs</h2>
                <p class="panel-subtitle">Approved volunteer hours by club or university unit.</p>
                <canvas id="clubChart"></canvas>
            </div>
            <div class="panel">
                <h2>Recent Hour Logs</h2>
                <p class="panel-subtitle">Latest volunteer hour submissions across the system.</p>
                <div class="table-wrap">
                    <table class="compact-table">
                        <thead><tr><th>Student</th><th>Event</th><th>Hours</th><th>Status</th><th>Submitted</th></tr></thead>
                        <tbody>
                        <c:forEach var="log" items="${recentLogs}">
                            <tr>
                                <td><c:out value="${log.studentName}"/></td>
                                <td><c:out value="${log.eventTitle}"/></td>
                                <td>${log.hoursClaimed}</td>
                                <td><span class="pill ${log.status eq 'approved' ? 'green' : (log.status eq 'pending' ? 'amber' : 'red')}">${log.status}</span></td>
                                <td><fmt:formatDate value="${log.submittedAt}" pattern="dd MMM yyyy"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </c:otherwise>
</c:choose>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
const facultyLabels = [<c:forEach var="row" items="${facultyHours}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const facultyValues = [<c:forEach var="row" items="${facultyHours}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];
const clubLabels = [<c:forEach var="row" items="${topClubs}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const clubValues = [<c:forEach var="row" items="${topClubs}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];
const monthLabels = [<c:forEach var="row" items="${monthlyTrend}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const monthValues = [<c:forEach var="row" items="${monthlyTrend}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];

function barChart(id, labels, values, color) {
  new Chart(document.getElementById(id), {
    type: "bar",
    data: { labels, datasets: [{ data: values, backgroundColor: color, borderRadius: 6 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
  });
}
(() => {
    const modal = document.querySelector("#badgeInfoModal");
    const openBtn = document.querySelector("#badgeInfoBtn");
    if (!modal || !openBtn) return;

    function open() {
        modal.hidden = false;
        document.body.classList.add("modal-open");
    }
    function close() {
        modal.hidden = true;
        document.body.classList.remove("modal-open");
    }

    openBtn.addEventListener("click", open);
    document.querySelectorAll("[data-badge-info-close]").forEach((b) => b.addEventListener("click", close));
    modal.addEventListener("click", (e) => { if (e.target === modal) close(); });
    document.addEventListener("keydown", (e) => { if (e.key === "Escape" && !modal.hidden) close(); });
})();

new Chart(document.getElementById("facultyChart"), {
  type: "bar",
  data: { labels: facultyLabels, datasets: [{ data: facultyValues, backgroundColor: "#2563eb", borderRadius: 6 }] },
  options: {
    indexAxis: "y",
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: { y: { ticks: { autoSkip: false } } }
  }
});
barChart("clubChart", clubLabels, clubValues, "#0f8b63");
new Chart(document.getElementById("monthlyChart"), {
  type: "line",
  data: { labels: monthLabels, datasets: [{ data: monthValues, borderColor: "#d97706", backgroundColor: "rgba(217,119,6,.15)", tension: .35, fill: true }] },
  options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
});
</script>

<%@ include file="../includes/layout-end.jspf" %>
