package com.impactsiswa.filter;

import com.impactsiswa.model.User;
import com.impactsiswa.util.Flash;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter("/app/*")
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        User currentUser = (User) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            Flash.error(req, "Please login before opening the dashboard.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        if ((path.startsWith("/app/users") || path.startsWith("/app/affiliations")) && !currentUser.isAdmin()) {
            Flash.error(req, "Only admins can manage user roles, faculties, and clubs.");
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
            return;
        }

        if (currentUser.isStudent() && (
                path.startsWith("/app/approvals")
                        || path.startsWith("/app/manage-events")
                        || path.startsWith("/app/reports")
                        || path.startsWith("/app/users")
                        || path.startsWith("/app/affiliations"))) {
            Flash.error(req, "That page is only available for club leaders and admins.");
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
            return;
        }

        // This filter is the main session gate for all protected application pages.
        chain.doFilter(request, response);
    }
}
