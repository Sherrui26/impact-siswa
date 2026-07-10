<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Reports" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Report Generation</h1>
        <p>Volunteer impact reports for faculty hours, active organizers, monthly trends, and approvals.</p>
    </div>
    <span class="pill green">Live reports</span>
</div>

<div class="grid stats-grid">
    <div class="stat-card"><span>Total University Impact</span><strong>${stats.totalUniversityHours}</strong><em>Approved hours</em></div>
    <div class="stat-card"><span>Open Events</span><strong>${stats.openEvents}</strong><em>Active opportunities</em></div>
    <div class="stat-card"><span>Approved Logs</span><strong>${stats.approvedLogs}</strong><em>Verified claims</em></div>
    <div class="stat-card"><span>Pending Summary</span><strong>${stats.pendingApprovals}</strong><em>Claims waiting</em></div>
</div>

<div class="grid report-grid" style="margin-top:18px;">
    <div class="panel chart-box"><h2>Hours by Faculty</h2><p class="panel-subtitle">Approved hours by faculty.</p><canvas id="facultyChart"></canvas></div>
    <div class="panel chart-box"><h2>Top 5 Organizers/Clubs</h2><p class="panel-subtitle">Approved volunteer hours by club or university unit.</p><canvas id="clubChart"></canvas></div>
    <div class="panel chart-box"><h2>Monthly Hours Trend</h2><p class="panel-subtitle">Line chart report.</p><canvas id="monthlyChart"></canvas></div>
    <div class="panel">
        <h2>Recent Hour Logs</h2>
        <p class="panel-subtitle">Operational table for recent submissions.</p>
        <div class="table-wrap">
            <table>
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

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
const facultyLabels = [<c:forEach var="row" items="${facultyHours}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const facultyValues = [<c:forEach var="row" items="${facultyHours}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];
const clubLabels = [<c:forEach var="row" items="${topClubs}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const clubValues = [<c:forEach var="row" items="${topClubs}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];
const monthLabels = [<c:forEach var="row" items="${monthlyTrend}" varStatus="s">"${row.label}"${s.last ? "" : ","}</c:forEach>];
const monthValues = [<c:forEach var="row" items="${monthlyTrend}" varStatus="s">${row.value}${s.last ? "" : ","}</c:forEach>];
function barChart(id, labels, values, color) {
  const canvas = document.getElementById(id);
  const ctx = canvas.getContext("2d");
  const gradient = ctx.createLinearGradient(0, 0, canvas.offsetWidth || 520, 0);
  gradient.addColorStop(0, color);
  gradient.addColorStop(1, color === "#2563eb" ? "#0f8b63" : "#22c55e");
  new Chart(canvas, {
    type: "bar",
    data: { labels, datasets: [{ data: values, backgroundColor: gradient, borderRadius: 999, borderSkipped: false, barThickness: 18, maxBarThickness: 22 }] },
    options: {
      indexAxis: "y",
      responsive: true,
      maintainAspectRatio: false,
      layout: { padding: { top: 6, right: 18, bottom: 6, left: 0 } },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "#152033",
          padding: 12,
          displayColors: false,
          callbacks: { label: (context) => context.parsed.x + " approved hours" }
        }
      },
      scales: {
        x: {
          beginAtZero: true,
          grid: { color: "rgba(101, 113, 132, .16)", drawBorder: false },
          ticks: { color: "#657184", precision: 0 }
        },
        y: {
          grid: { display: false, drawBorder: false },
          ticks: { color: "#152033", font: { weight: 800 } }
        }
      }
    }
  });
}
barChart("facultyChart", facultyLabels, facultyValues, "#2563eb");
barChart("clubChart", clubLabels, clubValues, "#0f8b63");
new Chart(document.getElementById("monthlyChart"), { type: "line", data: { labels: monthLabels, datasets: [{ data: monthValues, borderColor: "#d97706", backgroundColor: "rgba(217,119,6,.15)", tension: .35, fill: true }] }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } } });
</script>

<%@ include file="../includes/layout-end.jspf" %>
