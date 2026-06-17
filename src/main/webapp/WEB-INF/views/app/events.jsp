<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Events" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Volunteer Events</h1>
        <p>Browse opportunities and request to join. Approved registrations can be used for hour claims.</p>
    </div>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Event</th><th>Category</th><th>Date</th><th>Location</th><th>Hours</th><th>Slots Left</th><th>Action</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="event" items="${events}">
                <tr>
                    <td><strong><c:out value="${event.title}"/></strong><br><span class="label"><c:out value="${event.creatorName}"/></span></td>
                    <td><span class="pill"><c:out value="${event.categoryName}"/></span></td>
                    <td><fmt:formatDate value="${event.eventDate}" pattern="dd MMM yyyy"/></td>
                    <td><c:out value="${event.location}"/></td>
                    <td>${event.hours}</td>
                    <td>${event.slotsLeft}</td>
                    <td>
                        <c:choose>
                            <c:when test="${sessionScope.currentUser.role eq 'student'}">
                                <form method="post" action="${ctx}/app/events">
                                    <input type="hidden" name="eventId" value="${event.eventId}">
                                    <c:choose>
                                        <c:when test="${event.registrationStatus eq 'approved'}">
                                            <input type="hidden" name="action" value="cancelJoin">
                                            <button class="btn ghost" type="button"
                                                    data-confirm-submit
                                                    data-confirm-tone="danger"
                                                    data-confirm-kicker="Cancel event registration"
                                                    data-confirm-title="<c:out value='${event.title}'/>"
                                                    data-confirm-message="Cancel your registration for this event?"
                                                    data-confirm-action="Yes, Cancel Registration"
                                                    data-confirm-icon="bi bi-x-circle">
                                                <i class="bi bi-x-circle"></i>Cancel
                                            </button>
                                        </c:when>
                                        <c:when test="${event.registrationStatus eq 'pending'}">
                                            <input type="hidden" name="action" value="cancelJoin">
                                            <button class="btn ghost" type="button"
                                                    data-confirm-submit
                                                    data-confirm-tone="danger"
                                                    data-confirm-kicker="Cancel join request"
                                                    data-confirm-title="<c:out value='${event.title}'/>"
                                                    data-confirm-message="Cancel your pending request for this event?"
                                                    data-confirm-action="Yes, Cancel Request"
                                                    data-confirm-icon="bi bi-x-circle">
                                                <i class="bi bi-hourglass-split"></i>Pending
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="hidden" name="action" value="join">
                                            <button class="btn success" type="button"
                                                    data-confirm-submit
                                                    data-confirm-kicker="${event.registrationStatus eq 'rejected' ? 'Request again' : 'Request event registration'}"
                                                    data-confirm-title="<c:out value='${event.title}'/>"
                                                    data-confirm-message="${event.registrationStatus eq 'rejected' ? 'Your previous request was rejected. Submit a new request?' : 'Submit a request to join this event?'}"
                                                    data-confirm-action="${event.registrationStatus eq 'rejected' ? 'Yes, Request Again' : 'Yes, Request to Join'}"
                                                    data-confirm-icon="bi bi-calendar-check"
                                                    ${event.slotsLeft le 0 ? 'disabled' : ''}>
                                                <i class="bi bi-plus-circle"></i>${event.registrationStatus eq 'rejected' ? 'Request Again' : 'Join'}
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <a class="btn" href="${ctx}/app/manage-events?edit=${event.eventId}"><i class="bi bi-pencil"></i>Edit</a>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/layout-end.jspf" %>
