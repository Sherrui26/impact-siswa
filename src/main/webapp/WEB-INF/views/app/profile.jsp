<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Profile" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Profile</h1>
        <p>Update your display information. Email, matric number, and role are controlled by registration/admin records.</p>
    </div>
</div>

<div class="panel" style="max-width:720px;">
    <form class="form-grid" method="post" action="${ctx}/app/profile">
        <div class="field"><label>Full Name</label><input name="fullName" value="<c:out value='${sessionScope.currentUser.fullName}'/>" required></div>
        <div class="form-grid two-col">
            <div class="field"><label>Email</label><input value="${sessionScope.currentUser.email}" disabled></div>
            <div class="field"><label>Matric Number</label><input value="${sessionScope.currentUser.matricNo}" disabled></div>
        </div>
        <div class="form-grid two-col">
            <div class="field"><label>Phone</label><input name="phone" value="<c:out value='${sessionScope.currentUser.phone}'/>" required></div>
            <div class="field">
                <label>${sessionScope.currentUser.role eq 'club_leader' ? 'Club' : (sessionScope.currentUser.role eq 'admin' ? 'University Unit' : 'Faculty')}</label>
                <select name="faculty" required>
                    <c:forEach var="item" items="${profileAffiliations}">
                        <option ${sessionScope.currentUser.faculty eq item.name ? 'selected' : ''}><c:out value="${item.name}"/></option>
                    </c:forEach>
                </select>
            </div>
        </div>
        <button class="btn primary" type="button"
                data-confirm-submit
                data-confirm-kicker="Update profile"
                data-confirm-title="Save Profile Changes"
                data-confirm-message="Save these changes to your profile?"
                data-confirm-action="Yes, Update Profile"
                data-confirm-icon="bi bi-save">
            <i class="bi bi-save"></i>Update Profile
        </button>
    </form>
</div>

<%@ include file="../includes/layout-end.jspf" %>
