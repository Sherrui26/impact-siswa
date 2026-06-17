<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard" />
<%@ include file="../includes/layout-start.jspf" %>
<c:choose>
    <c:when test="${sessionScope.currentUser.badgeName eq 'Gold' || sessionScope.currentUser.badgeName eq 'Platinum'}"><c:set var="dashboardBadgeImage" value="${ctx}/images/gold.png" /></c:when>
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
    </div>
    </c:if>
</div>

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
        <c:if test="${sessionScope.currentUser.role eq 'student'}">
        <div class="panel">
            <h2>Upcoming Events</h2>
            <p class="panel-subtitle">Events students can request to join next.</p>
            <div class="event-list">
                <c:forEach var="event" items="${events}" varStatus="loop">
                    <c:if test="${loop.index lt 3}">
                        <article class="event-card">
                            <h3><c:out value="${event.title}"/></h3>
                            <div class="event-meta">
                                <span class="pill"><c:out value="${event.categoryName}"/></span>
                                <span class="pill green"><fmt:formatDate value="${event.eventDate}" pattern="dd MMM yyyy"/></span>
                                <span class="pill amber">${event.hours} hours</span>
                            </div>
                        </article>
                    </c:if>
                </c:forEach>
            </div>
        </div>
        </c:if>
    </div>
</div>

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
barChart("facultyChart", facultyLabels, facultyValues, "#2563eb");
barChart("clubChart", clubLabels, clubValues, "#0f8b63");
new Chart(document.getElementById("monthlyChart"), {
  type: "line",
  data: { labels: monthLabels, datasets: [{ data: monthValues, borderColor: "#d97706", backgroundColor: "rgba(217,119,6,.15)", tension: .35, fill: true }] },
  options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
});
</script>

<%@ include file="../includes/layout-end.jspf" %>
