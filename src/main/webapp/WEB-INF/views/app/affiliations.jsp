<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Faculties & Clubs" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Faculties & Clubs</h1>
        <p>Manage the faculties, clubs, and university units used in registration, user assignment, and reports.</p>
    </div>
    <c:if test="${not empty editingAffiliation}">
        <a class="btn" href="${ctx}/app/affiliations"><i class="bi bi-plus-lg"></i>New Entry</a>
    </c:if>
</div>

<div class="hours-stack">
    <div class="panel claim-panel">
        <div class="claim-header">
            <div>
                <span class="form-eyebrow">${empty editingAffiliation ? 'New record' : 'Update record'}</span>
                <h2>${empty editingAffiliation ? 'Add Faculty or Club' : 'Edit Faculty or Club'}</h2>
                <p class="panel-subtitle">Active records appear in dropdowns for registration, profile, and admin user assignment.</p>
            </div>
        </div>
        <form class="form-grid affiliation-form" method="post" action="${ctx}/app/affiliations">
            <input type="hidden" name="affiliationId" value="${editingAffiliation.affiliationId}">
            <div class="affiliation-form-grid">
                <div class="field affiliation-name-field">
                    <label>Name</label>
                    <input name="name" value="<c:out value='${editingAffiliation.name}'/>" placeholder="Example: Entrepreneurship Club" required>
                </div>
                <div class="field">
                    <label>Type</label>
                    <select name="type" required>
                        <option value="faculty" ${editingAffiliation.type eq 'faculty' ? 'selected' : ''}>Faculty</option>
                        <option value="club" ${editingAffiliation.type eq 'club' ? 'selected' : ''}>Club</option>
                        <option value="unit" ${editingAffiliation.type eq 'unit' ? 'selected' : ''}>University Unit</option>
                    </select>
                </div>
                <label class="check-card">
                    <input type="checkbox" name="active" ${empty editingAffiliation || editingAffiliation.active ? 'checked' : ''}>
                    <span>
                        <strong>Active</strong>
                        <em>Show this in dropdowns</em>
                    </span>
                </label>
                <div class="event-form-action">
                    <button class="btn success" type="button"
                            data-confirm-submit
                            data-confirm-kicker="${empty editingAffiliation ? 'Add faculty or club' : 'Save faculty or club'}"
                            data-confirm-title="${empty editingAffiliation ? 'Create Managed Record' : 'Update Managed Record'}"
                            data-confirm-message="${empty editingAffiliation ? 'Add this faculty, club, or university unit to the managed list?' : 'Save changes to this faculty, club, or university unit?'}"
                            data-confirm-action="${empty editingAffiliation ? 'Yes, Add Entry' : 'Yes, Save Changes'}"
                            data-confirm-icon="bi bi-save">
                        <i class="bi bi-save"></i>${empty editingAffiliation ? 'Add Entry' : 'Save Changes'}
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="panel history-panel">
        <h2>Current List</h2>
        <p class="panel-subtitle">Keep inactive records for history, or delete entries created by mistake.</p>
        <div class="table-wrap">
            <table class="event-record-table">
                <thead><tr><th>Name</th><th>Type</th><th>Status</th><th>Actions</th></tr></thead>
                <tbody>
                <c:forEach var="item" items="${affiliations}">
                    <tr>
                        <td><strong><c:out value="${item.name}"/></strong></td>
                        <td>${item.typeLabel}</td>
                        <td><span class="pill ${item.active ? 'green' : 'amber'}">${item.active ? 'active' : 'inactive'}</span></td>
                        <td>
                            <div class="table-actions">
                                <a class="btn" href="${ctx}/app/affiliations?edit=${item.affiliationId}"><i class="bi bi-pencil"></i>Edit</a>
                                <form method="post" action="${ctx}/app/affiliations">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="affiliationId" value="${item.affiliationId}">
                                    <button class="btn danger" type="button"
                                            data-confirm-submit
                                            data-confirm-tone="danger"
                                            data-confirm-kicker="Delete faculty or club"
                                            data-confirm-title="<c:out value='${item.name}'/>"
                                            data-confirm-message="Delete this record from the managed list?"
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

<%@ include file="../includes/layout-end.jspf" %>
