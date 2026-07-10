package com.impactsiswa.servlet;

import com.impactsiswa.dao.UserDAO;
import com.impactsiswa.dao.AffiliationDAO;
import com.impactsiswa.model.User;
import com.impactsiswa.util.Flash;
import com.impactsiswa.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet({"/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AffiliationDAO affiliationDAO = new AffiliationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/logout".equals(path)) {
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        req.setAttribute("mode", "/register".equals(path) ? "register" : "login");
        if ("/register".equals(path)) {
            req.setAttribute("faculties", affiliationDAO.findActiveByType("faculty"));
        }
        req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        if ("/register".equals(req.getServletPath())) {
            register(req, resp);
        } else {
            login(req, resp);
        }
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String login = value(req, "login");
        String password = value(req, "password");
        User user;
        try {
            user = userDAO.findByLogin(login);
        } catch (IllegalStateException e) {
            req.setAttribute("mode", "login");
            req.setAttribute("error", "Database connection failed. Please start MySQL, import database/impact_siswa.sql, and check the MySQL username/password.");
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }

        if (user == null || !PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            req.setAttribute("mode", "login");
            req.setAttribute("error", "Invalid email/matric number or password.");
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }

        req.getSession(true).setAttribute("currentUser", user);
        Flash.success(req, "Welcome back, " + user.getFullName() + ".");
        resp.sendRedirect(req.getContextPath() + "/app/dashboard");
    }

    private void register(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String password = value(req, "password");
        String confirmPassword = value(req, "confirmPassword");
        if (password.length() < 8) {
            req.setAttribute("mode", "register");
            req.setAttribute("faculties", affiliationDAO.findActiveByType("faculty"));
            req.setAttribute("error", "Please use a password with at least 8 characters.");
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirmPassword)) {
            req.setAttribute("mode", "register");
            req.setAttribute("faculties", affiliationDAO.findActiveByType("faculty"));
            req.setAttribute("error", "Passwords do not match. Please re-enter them.");
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setFullName(value(req, "fullName"));
        user.setMatricNo(value(req, "matricNo"));
        user.setEmail(value(req, "email"));
        user.setPhone(value(req, "phone"));
        user.setFaculty(value(req, "faculty"));
        user.setRole("student");
        user.setPasswordHash(PasswordUtil.hashPassword(password));

        try {
            userDAO.create(user);
            req.getSession(true).setAttribute("currentUser", userDAO.findById(user.getUserId()));
            Flash.success(req, "Account created successfully.");
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
        } catch (IllegalStateException e) {
            req.setAttribute("mode", "register");
            req.setAttribute("faculties", affiliationDAO.findActiveByType("faculty"));
            req.setAttribute("error", "Unable to register. The email or matric number may already exist.");
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
        }
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
