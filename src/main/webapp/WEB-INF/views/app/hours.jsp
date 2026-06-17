<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="My Hours" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>My Hours</h1>
        <p>Submit completed volunteer hours and track approval status.</p>
    </div>
</div>

<div class="hours-stack">
    <div class="panel claim-panel">
        <div class="claim-header">
            <div>
                <h2>Submit Hour Claim</h2>
                <p class="panel-subtitle">Only approved event registrations can be selected for hour claims.</p>
            </div>
        </div>
        <form id="hourClaimForm" class="form-grid claim-form clean-claim-form" method="post" action="${ctx}/app/hours" enctype="multipart/form-data">
            <div class="claim-fields">
                <div class="field">
                    <label>Volunteer Event</label>
                    <select name="eventId" required ${empty events ? 'disabled' : ''}>
                            <c:choose>
                                <c:when test="${empty events}">
                                <option>No claimable approved events</option>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="event" items="${events}">
                                    <option value="${event.eventId}">${event.title}</option>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </select>
                </div>
                <div class="field"><label>Hours Claimed</label><input type="number" step="0.5" min="0.5" max="24" name="hoursClaimed" value="4.00" required></div>
                <div class="claim-action">
                    <button class="btn success" type="button"
                            data-confirm-submit
                            data-confirm-kicker="Submit hour claim"
                            data-confirm-title="Send for Review"
                            data-confirm-message="Submit this volunteer hour claim to a club leader or admin for verification?"
                            data-confirm-action="Yes, Submit Claim"
                            data-confirm-icon="bi bi-send"
                            ${empty events ? 'disabled' : ''}>
                        <i class="bi bi-send"></i>Submit Claim
                    </button>
                </div>
            </div>
            <c:if test="${empty events}">
                <div class="empty-state"><strong>No events available for a new claim.</strong><p class="muted">Approved events appear here only until you submit a pending or approved hour claim. Rejected claims can be corrected and submitted again.</p></div>
            </c:if>
            <div class="claim-evidence-grid">
                <div class="field">
                    <label>Evidence / Remarks</label>
                    <textarea class="compact-textarea" name="evidence" placeholder="Supervisor name, attendance note, or short explanation"></textarea>
                </div>
                <div class="field">
                    <label>Proof Image</label>
                    <label class="file-picker" for="proofImage">
                        <i class="bi bi-image"></i>
                        <span id="proofImageName">Attach JPG, PNG, WEBP, or GIF</span>
                    </label>
                    <input class="file-input" id="proofImage" type="file" name="proofImage" accept="image/jpeg,image/png,image/webp,image/gif">
                </div>
            </div>
        </form>
    </div>

    <div class="panel history-panel">
        <h2>Submission History</h2>
        <p class="panel-subtitle">Pending, approved, and rejected logs with approval details.</p>
        <c:choose>
            <c:when test="${empty logs}">
                <div class="empty-state"><strong>No hour submissions yet.</strong><p class="muted">Submit your first claim after completing a volunteer event.</p></div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Event</th><th>Hours</th><th>Submitted</th><th>Status</th><th>Approval Details</th><th>Action</th></tr></thead>
                        <tbody>
                        <c:forEach var="log" items="${logs}">
                            <fmt:formatDate value="${log.submittedAt}" pattern="dd MMM yyyy HH:mm" var="submittedText"/>
                            <fmt:formatDate value="${log.approvedAt}" pattern="dd MMM yyyy HH:mm" var="approvedText"/>
                            <c:set var="proofUrl" value="" />
                            <c:if test="${not empty log.proofImage}">
                                <c:url var="proofUrl" value="/app/proofs/${log.proofImage}" />
                            </c:if>
                            <tr>
                                <td>
                                    <strong><c:out value="${log.eventTitle}"/></strong><br>
                                    <span class="label"><c:out value="${empty log.evidence ? 'No written note submitted.' : log.evidence}"/></span>
                                </td>
                                <td>${log.hoursClaimed}</td>
                                <td>${submittedText}</td>
                                <td><span class="pill ${log.status eq 'approved' ? 'green' : (log.status eq 'pending' ? 'amber' : 'red')}">${log.status}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty log.approverName}">
                                            <c:out value="${log.approverName}"/><br><span class="label"><fmt:formatDate value="${log.approvedAt}" pattern="dd MMM yyyy HH:mm"/></span>
                                        </c:when>
                                        <c:otherwise><span class="label">Waiting for review</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <button class="btn js-view-claim" type="button"
                                                data-detail-event="<c:out value='${log.eventTitle}'/>"
                                                data-detail-status="<c:out value='${log.status}'/>"
                                                data-detail-hours="<c:out value='${log.hoursClaimed}'/>"
                                                data-detail-submitted="<c:out value='${submittedText}'/>"
                                                data-detail-evidence="<c:out value='${log.evidence}'/>"
                                                data-detail-proof="<c:out value='${proofUrl}'/>"
                                                data-detail-remarks="<c:out value='${log.remarks}'/>"
                                                data-detail-approver="<c:out value='${log.approverName}'/>"
                                                data-detail-approved-at="<c:out value='${approvedText}'/>">
                                            <i class="bi bi-eye"></i>View
                                        </button>
                                        <c:if test="${log.status eq 'pending'}">
                                        <form method="post" action="${ctx}/app/hours">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="logId" value="${log.logId}">
                                            <button class="btn danger" type="button"
                                                    data-confirm-submit
                                                    data-confirm-tone="danger"
                                                    data-confirm-kicker="Cancel hour claim"
                                                    data-confirm-title="<c:out value='${log.eventTitle}'/>"
                                                    data-confirm-message="Cancel this pending submission?"
                                                    data-confirm-action="Yes, Cancel Claim"
                                                    data-confirm-icon="bi bi-x-circle">
                                                <i class="bi bi-x-circle"></i>Cancel
                                            </button>
                                        </form>
                                        </c:if>
                                    </div>
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

<div class="modal-backdrop" id="claimDetailModal" hidden>
    <div class="detail-dialog" role="dialog" aria-modal="true" aria-labelledby="claimDetailTitle">
        <div class="detail-header">
            <div>
                <p class="confirm-kicker" id="claimDetailStatus">Hour claim</p>
                <h2 id="claimDetailTitle">Claim details</h2>
            </div>
            <button class="icon-btn" type="button" data-detail-close aria-label="Close details"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="detail-grid">
            <div><span>Hours</span><strong id="claimDetailHours">0.00</strong></div>
            <div><span>Submitted</span><strong id="claimDetailSubmitted">-</strong></div>
            <div><span>Reviewer</span><strong id="claimDetailApprover">Waiting for review</strong></div>
        </div>
        <div class="detail-section">
            <h3>Evidence Note</h3>
            <p id="claimDetailEvidence" class="muted">No written note submitted.</p>
        </div>
        <div class="detail-section" id="claimDetailProofSection">
            <h3>Proof Image</h3>
            <img id="claimDetailProof" class="proof-preview" alt="Submitted proof image">
        </div>
        <div class="detail-section">
            <h3>Approval Remarks</h3>
            <p id="claimDetailRemarks" class="muted">Waiting for review.</p>
        </div>
    </div>
</div>

<script>
(() => {
    const imageInput = document.querySelector("#proofImage");
    const imageName = document.querySelector("#proofImageName");
    if (imageInput && imageName) {
        imageInput.addEventListener("change", () => {
            imageName.textContent = imageInput.files.length ? imageInput.files[0].name : "Attach JPG, PNG, WEBP, or GIF";
        });
    }

    const modal = document.querySelector("#claimDetailModal");
    if (!modal) return;

    const title = document.querySelector("#claimDetailTitle");
    const status = document.querySelector("#claimDetailStatus");
    const hours = document.querySelector("#claimDetailHours");
    const submitted = document.querySelector("#claimDetailSubmitted");
    const approver = document.querySelector("#claimDetailApprover");
    const evidence = document.querySelector("#claimDetailEvidence");
    const remarks = document.querySelector("#claimDetailRemarks");
    const proofSection = document.querySelector("#claimDetailProofSection");
    const proof = document.querySelector("#claimDetailProof");

    function textOrFallback(value, fallback) {
        return value && value.trim() ? value : fallback;
    }

    function closeDetails() {
        modal.hidden = true;
        document.body.classList.remove("modal-open");
        proof.removeAttribute("src");
    }

    document.querySelectorAll(".js-view-claim").forEach((button) => {
        button.addEventListener("click", () => {
            title.textContent = button.dataset.detailEvent || "Claim details";
            status.textContent = textOrFallback(button.dataset.detailStatus, "Hour claim");
            hours.textContent = textOrFallback(button.dataset.detailHours, "0.00");
            submitted.textContent = textOrFallback(button.dataset.detailSubmitted, "-");
            evidence.textContent = textOrFallback(button.dataset.detailEvidence, "No written note submitted.");

            const reviewer = textOrFallback(button.dataset.detailApprover, "Waiting for review");
            const approvedAt = textOrFallback(button.dataset.detailApprovedAt, "");
            approver.textContent = approvedAt ? reviewer + " / " + approvedAt : reviewer;
            remarks.textContent = textOrFallback(button.dataset.detailRemarks, "Waiting for review.");

            const proofUrl = textOrFallback(button.dataset.detailProof, "");
            if (proofUrl) {
                proof.src = proofUrl;
                proofSection.hidden = false;
            } else {
                proofSection.hidden = true;
            }

            modal.hidden = false;
            document.body.classList.add("modal-open");
        });
    });

    document.querySelectorAll("[data-detail-close]").forEach((button) => {
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
