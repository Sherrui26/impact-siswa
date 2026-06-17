<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Users" />
<%@ include file="../includes/layout-start.jspf" %>

<div class="page-heading">
    <div>
        <h1>Admin User Panel</h1>
        <p>Review accounts, assign roles, and connect each user to the right faculty, club, or university unit.</p>
    </div>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead><tr><th>Name</th><th>Matric</th><th>Email</th><th>Affiliation</th><th>Total Hours</th><th>Role & Assignment</th></tr></thead>
            <tbody>
            <c:forEach var="item" items="${users}">
                <tr>
                    <td><strong><c:out value="${item.fullName}"/></strong><br><span class="label">${item.phone}</span></td>
                    <td>${item.matricNo}</td>
                    <td><c:out value="${item.email}"/></td>
                    <td><c:out value="${item.faculty}"/></td>
                    <td>${item.totalHours}</td>
                    <td>
                        <form class="user-assignment-form" method="post" action="${ctx}/app/users">
                            <input type="hidden" name="userId" value="${item.userId}">
                            <select class="table-input" name="role">
                                <option value="student" ${item.role eq 'student' ? 'selected' : ''}>Student</option>
                                <option value="club_leader" ${item.role eq 'club_leader' ? 'selected' : ''}>Club Leader</option>
                                <option value="admin" ${item.role eq 'admin' ? 'selected' : ''}>Admin</option>
                            </select>
                            <select class="table-input" name="faculty">
                                <c:forEach var="affiliation" items="${affiliations}">
                                    <option value="<c:out value='${affiliation.name}'/>" ${item.faculty eq affiliation.name ? 'selected' : ''}>
                                        <c:out value="${affiliation.typeLabel}"/> - <c:out value="${affiliation.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                            <button class="btn" type="button"
                                    data-confirm-submit
                                    data-confirm-kicker="Update user access"
                                    data-confirm-title="<c:out value='${item.fullName}'/>"
                                    data-confirm-message="Save this user's role and faculty/club assignment?"
                                    data-confirm-action="Yes, Save User"
                                    data-confirm-icon="bi bi-save">
                                <i class="bi bi-save"></i>Save
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/layout-end.jspf" %>
