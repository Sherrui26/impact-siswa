package com.impactsiswa.servlet;

import com.impactsiswa.dao.AffiliationDAO;
import com.impactsiswa.dao.UserDAO;
import com.impactsiswa.model.User;
import com.impactsiswa.util.Flash;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/profile")
public class ProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AffiliationDAO affiliationDAO = new AffiliationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        req.setAttribute("activePage", "profile");
        req.setAttribute("profileAffiliations", affiliationDAO.findActiveByType(typeFor(user)));
        req.getRequestDispatcher("/WEB-INF/views/app/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        user.setFullName(value(req, "fullName"));
        user.setPhone(value(req, "phone"));
        user.setFaculty(value(req, "faculty"));
        userDAO.updateProfile(user);
        req.getSession().setAttribute("currentUser", userDAO.findById(user.getUserId()));
        Flash.success(req, "Profile updated.");
        resp.sendRedirect(req.getContextPath() + "/app/profile");
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private String typeFor(User user) {
        if (user.isClubLeader()) {
            return "club";
        }
        if (user.isAdmin()) {
            return "unit";
        }
        return "faculty";
    }
}
