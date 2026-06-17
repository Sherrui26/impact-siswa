<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Approvals" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Pending Approvals</h1>
        <p>Review event join requests first, then verify submitted volunteer hour claims.</p>
    </div>
    <span class="pill amber">${fn:length(pendingRegistrations) + fn:length(pendingLogs)} pending</span>
</div>

<div class="hours-stack">
    <div class="panel history-panel">
        <div class="section-title">
            <div>
                <h2>Event Join Requests</h2>
                <p class="panel-subtitle">Approve students before they are officially registered for an event.</p>
            </div>
            <div class="table-actions">
                <span class="pill amber">${fn:length(pendingRegistrations)} waiting</span>
                <c:if test="${not empty pendingRegistrations}">
                    <form method="post" action="${ctx}/app/approvals">
                        <input type="hidden" name="action" value="approveAllRegistrations">
                        <button class="btn success" type="button"
                                data-confirm-submit
                                data-confirm-kicker="Approve all join requests"
                                data-confirm-title="Approve All Students"
                                data-confirm-message="Approve every pending event join request currently available to your role?"
                                data-confirm-action="Yes, Approve All"
                                data-confirm-icon="bi bi-check2-all">
                            <i class="bi bi-check2-all"></i>Approve All Students
                        </button>
                    </form>
                </c:if>
            </div>
        </div>
        <c:choose>
            <c:when test="${empty pendingRegistrations}">
                <div class="empty-state"><strong>No event requests waiting.</strong><p class="muted">New student join requests will appear here.</p></div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Student</th><th>Event</th><th>Date</th><th>Hours</th><th>Requested</th><th>Decision</th></tr></thead>
                        <tbody>
                        <c:forEach var="request" items="${pendingRegistrations}">
                            <tr>
                                <td><strong><c:out value="${request.studentName}"/></strong><br><span class="label">${request.matricNo} - <c:out value="${request.faculty}"/></span></td>
                                <td><strong><c:out value="${request.eventTitle}"/></strong><br><span class="label"><c:out value="${request.categoryName}"/> - <c:out value="${request.location}"/></span></td>
                                <td><fmt:formatDate value="${request.eventDate}" pattern="dd MMM yyyy"/></td>
                                <td>${request.hours}</td>
                                <td><fmt:formatDate value="${request.registeredAt}" pattern="dd MMM yyyy HH:mm"/></td>
                                <td>
                                    <form class="table-actions" method="post" action="${ctx}/app/approvals">
                                        <input type="hidden" name="action" value="registration">
                                        <input type="hidden" name="registrationId" value="${request.registrationId}">
                                        <button class="btn success" name="decision" value="approved" type="button"
                                                data-confirm-submit
                                                data-confirm-kicker="Approve event registration"
                                                data-confirm-title="<c:out value='${request.studentName}'/>"
                                                data-confirm-message="Approve this student to join <c:out value='${request.eventTitle}'/>?"
                                                data-confirm-action="Yes, Approve"
                                                data-confirm-icon="bi bi-check2-circle">
                                            <i class="bi bi-check2-circle"></i>Approve
                                        </button>
                                        <button class="btn danger" name="decision" value="rejected" type="button"
                                                data-confirm-submit
                                                data-confirm-tone="danger"
                                                data-confirm-kicker="Reject event registration"
                                                data-confirm-title="<c:out value='${request.studentName}'/>"
                                                data-confirm-message="Reject this student's request to join <c:out value='${request.eventTitle}'/>?"
                                                data-confirm-action="Yes, Reject"
                                                data-confirm-icon="bi bi-x-circle">
                                            <i class="bi bi-x-circle"></i>Reject
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="panel history-panel">
        <div class="section-title">
            <div>
                <h2>Hour Claims</h2>
                <p class="panel-subtitle">Verify completed volunteer hours after students submit evidence.</p>
            </div>
            <span class="pill amber">${fn:length(pendingLogs)} waiting</span>
        </div>
        <c:choose>
            <c:when test="${empty pendingLogs}">
                <div class="empty-state"><strong>No hour submissions waiting.</strong><p class="muted">Submitted volunteer hours will appear here for verification.</p></div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Student</th><th>Event</th><th>Hours</th><th>Submitted</th><th>Evidence</th><th>Decision</th></tr></thead>
                        <tbody>
                        <c:forEach var="log" items="${pendingLogs}">
                            <c:set var="proofUrl" value="" />
                            <c:if test="${not empty log.proofImage}">
                                <c:url var="proofUrl" value="/app/proofs/${log.proofImage}" />
                            </c:if>
                            <tr>
                                <td><strong><c:out value="${log.studentName}"/></strong><br><span class="label">${log.matricNo} - <c:out value="${log.faculty}"/></span></td>
                                <td><strong><c:out value="${log.eventTitle}"/></strong><br><span class="label"><c:out value="${log.categoryName}"/></span></td>
                                <td>${log.hoursClaimed}</td>
                                <td><fmt:formatDate value="${log.submittedAt}" pattern="dd MMM yyyy HH:mm"/></td>
                                <td>
                                    <c:out value="${empty log.evidence ? 'No written note submitted.' : log.evidence}"/>
                                    <c:if test="${not empty proofUrl}">
                                        <div style="margin-top:10px;">
                                            <a class="btn" href="${proofUrl}" target="_blank" rel="noopener">
                                                <i class="bi bi-eye"></i>View Proof
                                            </a>
                                        </div>
                                    </c:if>
                                </td>
                                <td>
                                    <form class="form-grid" method="post" action="${ctx}/app/approvals">
                                        <input type="hidden" name="action" value="hours">
                                        <input type="hidden" name="logId" value="${log.logId}">
                                        <div class="field"><textarea name="remarks" placeholder="Approval or rejection remarks"><c:out value="${log.remarks}"/></textarea></div>
                                        <div class="table-actions">
                                            <button class="btn success" name="decision" value="approved" type="button"
                                                    data-confirm-submit
                                                    data-confirm-kicker="Approve hour claim"
                                                    data-confirm-title="<c:out value='${log.studentName}'/>"
                                                    data-confirm-message="Approve ${log.hoursClaimed} volunteer hours for <c:out value='${log.eventTitle}'/>?"
                                                    data-confirm-action="Yes, Approve Hours"
                                                    data-confirm-icon="bi bi-check2-circle">
                                                <i class="bi bi-check2-circle"></i>Approve
                                            </button>
                                            <button class="btn danger" name="decision" value="rejected" type="button"
                                                    data-confirm-submit
                                                    data-confirm-tone="danger"
                                                    data-confirm-kicker="Reject hour claim"
                                                    data-confirm-title="<c:out value='${log.studentName}'/>"
                                                    data-confirm-message="Reject this ${log.hoursClaimed}-hour claim for <c:out value='${log.eventTitle}'/>?"
                                                    data-confirm-action="Yes, Reject Claim"
                                                    data-confirm-icon="bi bi-x-circle">
                                                <i class="bi bi-x-circle"></i>Reject
                                            </button>
                                        </div>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="../includes/layout-end.jspf" %>
