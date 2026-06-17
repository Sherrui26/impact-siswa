package com.impactsiswa.servlet;

import com.impactsiswa.dao.AffiliationDAO;
import com.impactsiswa.dao.UserDAO;
import com.impactsiswa.util.Flash;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/users")
public class UserAdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AffiliationDAO affiliationDAO = new AffiliationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("activePage", "users");
        req.setAttribute("users", userDAO.findAll());
        req.setAttribute("affiliations", affiliationDAO.findActive());
        req.getRequestDispatcher("/WEB-INF/views/app/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String role = value(req, "role");
        if (!("student".equals(role) || "club_leader".equals(role) || "admin".equals(role))) {
            Flash.error(req, "Invalid role selected.");
        } else {
            userDAO.updateRoleAndAffiliation(Integer.parseInt(value(req, "userId")), role, value(req, "faculty"));
            Flash.success(req, "User role and faculty/club updated.");
        }
        resp.sendRedirect(req.getContextPath() + "/app/users");
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
