

<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Manage Events" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Manage Events</h1>
        <p>Create, update, and delete volunteer opportunities for the marketplace.</p>
    </div>
    <c:if test="${not empty editingEvent}">
        <a class="btn" href="${ctx}/app/manage-events"><i class="bi bi-plus-lg"></i>New Event</a>
    </c:if>
</div>

<div class="hours-stack">
    <div class="panel claim-panel">
        <div class="claim-header">
            <div>
                <span class="form-eyebrow">${empty editingEvent ? 'New event' : 'Update event'}</span>
                <h2>${empty editingEvent ? 'Create Event' : 'Edit Event'}</h2>
                <p class="panel-subtitle">Published events appear in the student marketplace and can be joined for hour claims.</p>
            </div>
        </div>
        <form class="form-grid event-form" method="post" action="${ctx}/app/manage-events" enctype="multipart/form-data">
            <input type="hidden" name="eventId" value="${editingEvent.eventId}">
            <div class="event-form-grid">
                <div class="field event-title-field">
                    <label>Title</label>
                    <input name="title" value="<c:out value='${editingEvent.title}'/>" placeholder="Example: Campus Clean-Up Drive" required>
                </div>
                <div class="field">
                    <label>Category</label>
                    <select name="catId" required>
                        <option value="" disabled ${empty editingEvent ? 'selected' : ''}>Select category</option>
                        <c:forEach var="category" items="${categories}">
                            <option value="${category.catId}" ${editingEvent.catId eq category.catId ? 'selected' : ''}>
                                <c:out value="${category.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field">
                    <label>Status</label>
                    <select name="status">
                        <option value="open" ${empty editingEvent || editingEvent.status eq 'open' ? 'selected' : ''}>Open</option>
                        <option value="closed" ${editingEvent.status eq 'closed' ? 'selected' : ''}>Closed</option>
                    </select>
                </div>
                <div class="field">
                    <label>Event Date</label>
                    <input type="date" name="eventDate" value="<fmt:formatDate value='${editingEvent.eventDate}' pattern='yyyy-MM-dd'/>" required>
                </div>
                <div class="field event-location-field">
                    <label>Location</label>
                    <input name="location" value="<c:out value='${editingEvent.location}'/>" placeholder="Example: Main Hall, Block A" required>
                </div>
                <div class="field">
                    <label>Hours</label>
                    <input type="number" name="hours" min="0" step="0.25" value="<c:out value='${editingEvent.hours}'/>" placeholder="0.00" required>
                </div>
                <div class="field">
                    <label>Max Volunteers</label>
                    <input type="number" name="maxVolunteers" min="1" step="1" value="${editingEvent.maxVolunteers}" placeholder="20" required>
                </div>
                <div class="field event-description-field">
                    <label>Description</label>
                    <textarea name="description" rows="3" placeholder="Describe the activity, expectations, and what volunteers will do."><c:out value='${editingEvent.description}'/></textarea>
                </div>
                <div class="field event-image-field">
                    <label>Event Image <span class="muted">(optional, JPG/PNG/WEBP/GIF, max 5 MB)</span></label>
                    <c:set var="editingImageUrl" value="" />
                    <c:if test="${editingEvent.hasImage}"><c:url var="editingImageUrl" value="/app/event-images/${editingEvent.imagePath}" /></c:if>
                    <div class="event-image-picker-row">
                        <label class="file-picker" for="eventImage">
                            <i class="bi bi-image"></i>
                            <span id="eventImageName">${editingEvent.hasImage ? 'Change image (JPG, PNG, WEBP, or GIF)' : 'Attach JPG, PNG, WEBP, or GIF'}</span>
                        </label>
                        <img class="event-image-preview ${editingEvent.hasImage ? 'is-visible' : ''}" data-event-image-preview src="${editingImageUrl}" alt="Event image preview">
                    </div>
                    <input class="file-input" id="eventImage" type="file" name="image" accept="image/jpeg,image/png,image/webp,image/gif" data-event-image-input>
                    <c:if test="${editingEvent.hasImage}">
                        <label class="event-image-remove">
                            <input type="checkbox" name="removeImage" value="true">
                            Remove current image
                        </label>
                    </c:if>
                </div>
                <div class="event-form-action">
                    <button class="btn success" type="button"
                            data-confirm-submit
                            data-confirm-kicker="${empty editingEvent ? 'Create event' : 'Save event'}"
                            data-confirm-title="${empty editingEvent ? 'Publish New Event' : 'Update Event'}"
                            data-confirm-message="${empty editingEvent ? 'Publish this event to the volunteer marketplace?' : 'Save changes to this event?'}"
                            data-confirm-action="${empty editingEvent ? 'Yes, Publish Event' : 'Yes, Save Changes'}"
                            data-confirm-icon="bi bi-save">
                        <i class="bi bi-save"></i>${empty editingEvent ? 'Publish Event' : 'Save Changes'}
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel history-panel">
        <h2>All Events</h2>
        <p class="panel-subtitle">Edit details or remove events that are no longer needed.</p>
        <div class="table-wrap">
            <table class="event-record-table">
                <thead>
                <tr>
                    <th>Event</th><th>Category</th><th>Date</th><th>Location</th><th>Hours</th><th>Slots Left</th><th>Status</th><th>Actions</th>
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
                        <td><span class="pill ${event.status eq 'open' ? 'green' : 'amber'}"><c:out value="${event.status}"/></span></td>
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
                                            data-confirm-message="Delete this event? Existing registrations and claims for it may be affected."
                                            data-confirm-action="Yes, Delete"
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

<script>
(() => {
    const input = document.querySelector("[data-event-image-input]");
    const preview = document.querySelector("[data-event-image-preview]");
    const nameLabel = document.querySelector("#eventImageName");
    const removeCheckbox = document.querySelector(".event-image-remove input");
    if (!input) return;

    const defaultLabel = nameLabel ? nameLabel.textContent : "";

    input.addEventListener("change", () => {
        const file = input.files && input.files[0];
        if (!file) {
            if (nameLabel) nameLabel.textContent = defaultLabel;
            return;
        }
        if (nameLabel) nameLabel.textContent = file.name;
        // A newly chosen image cancels a pending removal.
        if (removeCheckbox) removeCheckbox.checked = false;
        if (preview) {
            const reader = new FileReader();
            reader.onload = (e) => {
                preview.src = e.target.result;
                preview.classList.add("is-visible");
            };
            reader.readAsDataURL(file);
        }
    });

    if (removeCheckbox && preview) {
        removeCheckbox.addEventListener("change", () => {
            if (removeCheckbox.checked) {
                preview.classList.remove("is-visible");
                input.value = "";
                if (nameLabel) nameLabel.textContent = defaultLabel;
            } else if (preview.getAttribute("src")) {
                preview.classList.add("is-visible");
            }
        });
    }
})();
</script>

<%@ include file="../includes/layout-end.jspf" %>
