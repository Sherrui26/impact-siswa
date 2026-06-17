<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <title>${mode eq 'register' ? 'Register' : 'Login'} - Impact-Siswa</title>
    <%@ include file="includes/head.jspf" %>
</head>
<body>
<main class="auth-page">
    <section class="auth-hero">
        <div class="brand-row row">
            <div class="brand-mark logo-mark">
                <img class="brand-logo-img" src="${ctx}/images/logo.png" alt="Impact-Siswa logo">
            </div>
            <div>
                <strong>Impact-Siswa</strong>
                <span style="display:block;color:rgba(255,255,255,.78);font-size:13px;">Volunteer Hours & Social Credit System</span>
            </div>
        </div>
        <div>
            <h1>Turn every volunteer effort into verified student impact.</h1>
            <p>Discover activities, record volunteer hours, earn recognition badges, and help the university see the difference students are making.</p>
        </div>
        <div class="hero-metrics">
            <div class="hero-metric"><strong>Join</strong><span>find volunteer activities that match your interests</span></div>
            <div class="hero-metric"><strong>Verify</strong><span>submit hours for club leader or admin approval</span></div>
            <div class="hero-metric"><strong>Grow</strong><span>earn badges and build your contribution record</span></div>
        </div>
    </section>

    <section class="auth-panel-wrap">
        <div class="auth-card">
            <h2>${mode eq 'register' ? 'Create account' : 'Sign in'}</h2>
            <p class="muted">${mode eq 'register' ? 'Create your student account. Club leader access is assigned by an admin after registration.' : 'Login with your email or matric number.'}</p>

            <c:if test="${not empty error}">
                <div class="alert error" style="margin-top:18px;"><c:out value="${error}"/></div>
            </c:if>
            <c:if test="${not empty sessionScope.flash_error}">
                <div class="alert error" style="margin-top:18px;"><c:out value="${sessionScope.flash_error}"/></div>
                <c:remove var="flash_error" scope="session"/>
            </c:if>

            <div class="tabs">
                <a class="tab ${mode ne 'register' ? 'active' : ''}" href="${ctx}/login">Login</a>
                <a class="tab ${mode eq 'register' ? 'active' : ''}" href="${ctx}/register">Register</a>
            </div>

            <c:choose>
                <c:when test="${mode eq 'register'}">
                    <form class="form-grid" action="${ctx}/register" method="post">
                        <div class="form-grid two-col">
                            <div class="field"><label>Full Name</label><input name="fullName" required></div>
                            <div class="field"><label>Matric Number</label><input name="matricNo" required></div>
                        </div>
                        <div class="form-grid two-col">
                            <div class="field"><label>Email</label><input type="email" name="email" required></div>
                            <div class="field"><label>Phone</label><input name="phone" required></div>
                        </div>
                        <div class="field">
                            <label>Faculty</label>
                            <select name="faculty" required>
                                <c:forEach var="faculty" items="${faculties}">
                                    <option><c:out value="${faculty.name}"/></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="field"><label>Password</label><input type="password" name="password" minlength="8" required></div>
                        <button class="btn primary" type="submit"><i class="bi bi-person-plus"></i>Create Account</button>
                    </form>
                </c:when>
                <c:otherwise>
                    <form class="form-grid" action="${ctx}/login" method="post">
                        <div class="field"><label>Email or Matric Number</label><input name="login" placeholder="student@impact.edu.my" required></div>
                        <div class="field"><label>Password</label><input type="password" name="password" placeholder="student123" required></div>
                        <button class="btn primary" type="submit"><i class="bi bi-box-arrow-in-right"></i>Login</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</main>
</body>
</html>
