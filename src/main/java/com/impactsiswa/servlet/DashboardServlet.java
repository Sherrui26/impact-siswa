package com.impactsiswa.servlet;

import com.impactsiswa.dao.EventDAO;
import com.impactsiswa.dao.HourLogDAO;
import com.impactsiswa.dao.ReportDAO;
import com.impactsiswa.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/dashboard")
public class DashboardServlet extends HttpServlet {
    private final EventDAO eventDAO = new EventDAO();
    private final HourLogDAO hourLogDAO = new HourLogDAO();
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        req.setAttribute("activePage", "dashboard");
        req.setAttribute("stats", reportDAO.dashboardStats(user));
        req.setAttribute("events", eventDAO.findAll(user.getUserId()));
        req.setAttribute("pendingRegistrations", eventDAO.findPendingRegistrations(user));
        req.setAttribute("pendingLogs", hourLogDAO.findPendingForReviewer(user));
        req.setAttribute("myLogs", hourLogDAO.findByUser(user.getUserId()));
        req.setAttribute("facultyHours", reportDAO.hoursByFaculty());
        req.setAttribute("topClubs", reportDAO.topClubs());
        req.setAttribute("monthlyTrend", reportDAO.monthlyTrend());
        req.setAttribute("recentLogs", hourLogDAO.findRecent(20));
        req.getRequestDispatcher("/WEB-INF/views/app/dashboard.jsp").forward(req, resp);
    }
}
