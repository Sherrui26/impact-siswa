package com.impactsiswa.servlet;

import com.impactsiswa.dao.HourLogDAO;
import com.impactsiswa.dao.ReportDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/reports")
public class ReportServlet extends HttpServlet {
    private final ReportDAO reportDAO = new ReportDAO();
    private final HourLogDAO hourLogDAO = new HourLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("activePage", "reports");
        req.setAttribute("stats", reportDAO.dashboardStats());
        req.setAttribute("facultyHours", reportDAO.hoursByFaculty());
        req.setAttribute("topClubs", reportDAO.topClubs());
        req.setAttribute("monthlyTrend", reportDAO.monthlyTrend());
        req.setAttribute("recentLogs", hourLogDAO.findRecent(20));
        req.getRequestDispatcher("/WEB-INF/views/app/reports.jsp").forward(req, resp);
    }
}
