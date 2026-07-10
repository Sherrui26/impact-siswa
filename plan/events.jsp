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

<div class="events-market-grid">
    <c:forEach var="event" items="${events}">
        <fmt:formatDate value="${event.eventDate}" pattern="dd MMM yyyy" var="eventDateText"/>
        <c:set var="eventVisualClass" value="event-visual-${event.catId}" />
        <article class="market-event-card">
            <button class="event-poster ${eventVisualClass} js-view-event" type="button"
                    data-event-title="<c:out value='${event.title}'/>"
                    data-event-category="<c:out value='${event.categoryName}'/>"
                    data-event-date="<c:out value='${eventDateText}'/>"
                    data-event-location="<c:out value='${event.location}'/>"
                    data-event-hours="<c:out value='${event.hours}'/>"
                    data-event-slots="<c:out value='${event.slotsLeft}'/>"
                    data-event-capacity="<c:out value='${event.joinedCount}'/>/<c:out value='${event.maxVolunteers}'/>"
                    data-event-organizer="<c:out value='${event.creatorName}'/>"
                    data-event-description="<c:out value='${event.description}'/>"
                    data-event-status="<c:out value='${event.status}'/>"
                    data-event-visual="<c:out value='${eventVisualClass}'/>">
                <span class="event-poster-shade"></span>
                <span class="event-poster-content">
                    <span class="event-poster-top">
                        <span class="pill poster-pill"><c:out value="${event.categoryName}"/></span>
                        <span class="pill poster-pill ${event.status eq 'open' ? 'green' : 'amber'}"><c:out value="${event.status}"/></span>
                    </span>
                    <span class="event-poster-title"><c:out value="${event.title}"/></span>
                    <span class="event-poster-meta">
                        <span><i class="bi bi-calendar-event"></i>${eventDateText}</span>
                        <span><i class="bi bi-geo-alt"></i><c:out value="${event.location}"/></span>
                    </span>
                    <span class="poster-cta"><i class="bi bi-eye"></i>View details</span>
                </span>
            </button>
            <div class="event-card-body">
                <p class="event-description-preview"><c:out value="${event.description}"/></p>
                <div class="event-stat-row">
                    <div><span>Hours</span><strong>${event.hours}</strong></div>
                    <div><span>Slots Left</span><strong>${event.slotsLeft}</strong></div>
                    <div><span>Organizer</span><strong><c:out value="${event.creatorName}"/></strong></div>
                </div>
                <div class="event-card-actions">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser.role eq 'student'}">
                            <c:choose>
                                <c:when test="${event.claimed}">
                                    <div class="event-status-stack">
                                        <span class="pill ${event.claimStatus eq 'pending' ? 'amber' : 'green'}">
                                            <i class="bi bi-check-circle"></i>&nbsp;Claimed (<fmt:formatNumber value="${event.claimedHours}" maxFractionDigits="2"/> Hours)
                                        </span>
                                        <c:if test="${event.claimStatus eq 'pending'}"><span class="label">Reviewing</span></c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
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
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <a class="btn" href="${ctx}/app/manage-events?edit=${event.eventId}"><i class="bi bi-pencil"></i>Edit</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </article>
    </c:forEach>
</div>

<div class="modal-backdrop" id="eventDetailModal" hidden>
    <div class="detail-dialog event-detail-dialog" role="dialog" aria-modal="true" aria-labelledby="eventDetailTitle">
        <div class="event-detail-hero" id="eventDetailHero">
            <button class="icon-btn event-detail-close" type="button" data-event-detail-close aria-label="Close details"><i class="bi bi-x-lg"></i></button>
            <div class="event-detail-hero-content">
                <div class="event-meta">
                    <span class="pill poster-pill" id="eventDetailCategory">Event</span>
                    <span class="pill poster-pill green" id="eventDetailStatus">open</span>
                </div>
                <h2 id="eventDetailTitle">Event details</h2>
                <p id="eventDetailOrganizer">Organizer</p>
            </div>
        </div>
        <div class="detail-grid event-detail-grid">
            <div><span>Date</span><strong id="eventDetailDate">-</strong></div>
            <div><span>Location</span><strong id="eventDetailLocation">-</strong></div>
            <div><span>Hours</span><strong id="eventDetailHours">0.00</strong></div>
            <div><span>Slots Left</span><strong id="eventDetailSlots">0</strong></div>
            <div><span>Approved / Max</span><strong id="eventDetailCapacity">0/0</strong></div>
            <div><span>Category</span><strong id="eventDetailCategoryText">Event</strong></div>
        </div>
        <div class="detail-section">
            <h3>About This Event</h3>
            <p id="eventDetailDescription" class="muted">No description available.</p>
        </div>
    </div>
</div>

<script>
(() => {
    const modal = document.querySelector("#eventDetailModal");
    if (!modal) return;

    const hero = document.querySelector("#eventDetailHero");
    const title = document.querySelector("#eventDetailTitle");
    const category = document.querySelector("#eventDetailCategory");
    const categoryText = document.querySelector("#eventDetailCategoryText");
    const status = document.querySelector("#eventDetailStatus");
    const organizer = document.querySelector("#eventDetailOrganizer");
    const date = document.querySelector("#eventDetailDate");
    const location = document.querySelector("#eventDetailLocation");
    const hours = document.querySelector("#eventDetailHours");
    const slots = document.querySelector("#eventDetailSlots");
    const capacity = document.querySelector("#eventDetailCapacity");
    const description = document.querySelector("#eventDetailDescription");

    function textOrFallback(value, fallback) {
        return value && value.trim() ? value : fallback;
    }

    function closeDetails() {
        modal.hidden = true;
        document.body.classList.remove("modal-open");
    }

    document.querySelectorAll(".js-view-event").forEach((button) => {
        button.addEventListener("click", () => {
            const eventStatus = textOrFallback(button.dataset.eventStatus, "open");
            const visualClass = textOrFallback(button.dataset.eventVisual, "event-visual-default");

            hero.className = "event-detail-hero " + visualClass;
            title.textContent = textOrFallback(button.dataset.eventTitle, "Event details");
            category.textContent = textOrFallback(button.dataset.eventCategory, "Event");
            categoryText.textContent = textOrFallback(button.dataset.eventCategory, "Event");
            status.textContent = eventStatus;
            status.className = "pill poster-pill " + (eventStatus === "open" ? "green" : "amber");
            organizer.textContent = textOrFallback(button.dataset.eventOrganizer, "Organizer");
            date.textContent = textOrFallback(button.dataset.eventDate, "-");
            location.textContent = textOrFallback(button.dataset.eventLocation, "-");
            hours.textContent = textOrFallback(button.dataset.eventHours, "0.00");
            slots.textContent = textOrFallback(button.dataset.eventSlots, "0");
            capacity.textContent = textOrFallback(button.dataset.eventCapacity, "0/0");
            description.textContent = textOrFallback(button.dataset.eventDescription, "No description available.");

            modal.hidden = false;
            document.body.classList.add("modal-open");
        });
    });

    document.querySelectorAll("[data-event-detail-close]").forEach((button) => {
        button.addEventListener("click", closeDetails);
    });

    modal.addEventListener("click", (event) => {
        if (event.target === modal) closeDetails();
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && !modal.hidden) closeDetails();
    });
})();
</script>

<%@ include file="../includes/layout-end.jspf" %>
