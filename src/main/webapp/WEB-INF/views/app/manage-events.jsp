<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Manage Events" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Manage Events</h1>
        <p>Create, update, and delete volunteer opportunities posted by leaders or admins.</p>
    </div>
    <c:if test="${not empty editingEvent}">
        <a class="btn" href="${ctx}/app/manage-events"><i class="bi bi-plus-lg"></i>New Event</a>
    </c:if>
</div>

<div class="hours-stack">
    <div class="panel claim-panel">
        <div class="claim-header">
            <div>
                <span class="form-eyebrow">${empty editingEvent ? 'New opportunity' : 'Update opportunity'}</span>
                <h2>${empty editingEvent ? 'Create Event' : 'Edit Event'}</h2>
                <p class="panel-subtitle">Published events appear in the student marketplace immediately.</p>
            </div>
        </div>
        <form class="form-grid event-form" method="post" action="${ctx}/app/manage-events">
            <input type="hidden" name="eventId" value="${editingEvent.eventId}">
            <div class="event-form-grid">
                <div class="field event-title-field">
                    <label>Title</label>
                    <input name="title" value="<c:out value='${editingEvent.title}'/>" required>
                </div>
                <div class="field">
                    <label>Category</label>
                    <select name="catId" required>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.catId}" ${editingEvent.catId eq cat.catId ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field">
                    <label>Date</label>
                    <input type="date" name="eventDate" value="${editingEvent.eventDate}" required>
                </div>
                <div class="field">
                    <label>Hours</label>
                    <input type="number" step="0.5" min="0.5" name="hours" value="${empty editingEvent ? '4.00' : editingEvent.hours}" required>
                </div>
                <div class="field">
                    <label>Max Volunteers</label>
                    <input type="number" min="1" name="maxVolunteers" value="${empty editingEvent ? '50' : editingEvent.maxVolunteers}" required>
                </div>
                <div class="field">
                    <label>Status</label>
                    <select name="status">
                        <option value="open" ${editingEvent.status eq 'open' ? 'selected' : ''}>Open</option>
                        <option value="closed" ${editingEvent.status eq 'closed' ? 'selected' : ''}>Closed</option>
                        <option value="cancelled" ${editingEvent.status eq 'cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                <div class="field event-location-field">
                    <label>Location</label>
                    <input name="location" value="<c:out value='${editingEvent.location}'/>" required>
                </div>
                <div class="field event-description-field">
                    <label>Description</label>
                    <textarea class="compact-textarea" name="description" required><c:out value="${editingEvent.description}"/></textarea>
                </div>
                <div class="event-form-action">
                    <button class="btn success" type="button"
                            data-confirm-submit
                            data-confirm-kicker="${empty editingEvent ? 'Create event' : 'Save event changes'}"
                            data-confirm-title="${empty editingEvent ? 'Publish Volunteer Event' : 'Update Volunteer Event'}"
                            data-confirm-message="${empty editingEvent ? 'Create this event and make it visible to students?' : 'Save these changes to the selected event?'}"
                            data-confirm-action="${empty editingEvent ? 'Yes, Create Event' : 'Yes, Save Changes'}"
                            data-confirm-icon="bi bi-save">
                        <i class="bi bi-save"></i>${empty editingEvent ? 'Create Event' : 'Save Changes'}
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel history-panel">
        <h2>Event Records</h2>
        <p class="panel-subtitle">Review upcoming opportunities, edit details, or remove cancelled records.</p>
        <div class="table-wrap">
            <table class="event-record-table">
                <thead><tr><th>Event</th><th>Date</th><th>Slots</th><th>Status</th><th>Actions</th></tr></thead>
                <tbody>
                <c:forEach var="event" items="${events}">
                    <tr>
                        <td><strong><c:out value="${event.title}"/></strong><br><span class="label">${event.categoryName} - <c:out value="${event.location}"/></span></td>
                        <td><fmt:formatDate value="${event.eventDate}" pattern="dd MMM yyyy"/></td>
                        <td>${event.joinedCount}/${event.maxVolunteers}</td>
                        <td><span class="pill ${event.status eq 'open' ? 'green' : 'amber'}">${event.status}</span></td>
                        <td>
                            <div class="table-actions">
                                <a class="btn" href="${ctx}/app/manage-events?edit=${event.eventId}"><i class="bi bi-pencil"></i>Edit</a>
                                <form method="post" action="${ctx}/app/manage-events">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="eventId" value="${event.eventId}">
                                    <button class="btn danger" type="button"
                                            data-confirm-submit
                                            data-confirm-tone="danger"
                                            data-confirm-kicker="Delete event"
                                            data-confirm-title="<c:out value='${event.title}'/>"
                                            data-confirm-message="Delete this event and its related registrations?"
                                            data-confirm-action="Yes, Delete Event"
                                            data-confirm-icon="bi bi-trash">
                                        <i class="bi bi-trash"></i>Delete
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%@ include file="../includes/layout-end.jspf" %>
