package com.impactsiswa.servlet;

import com.impactsiswa.dao.EventDAO;
import com.impactsiswa.dao.HourLogDAO;
import com.impactsiswa.dao.UserDAO;
import com.impactsiswa.model.User;
import com.impactsiswa.util.Flash;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/app/approvals")
public class ApprovalServlet extends HttpServlet {
    private final EventDAO eventDAO = new EventDAO();
    private final HourLogDAO hourLogDAO = new HourLogDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        req.setAttribute("activePage", "approvals");
        req.setAttribute("pendingRegistrations", eventDAO.findPendingRegistrations(user));
        req.setAttribute("pendingLogs", hourLogDAO.findPendingForReviewer(user));
        req.getRequestDispatcher("/WEB-INF/views/app/approvals.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        String action = value(req, "action");

        if ("approveAllRegistrations".equals(action)) {
            int approvedCount = eventDAO.approveAllPendingRegistrations(user);
            Flash.success(req, approvedCount + " event join request" + (approvedCount == 1 ? "" : "s") + " approved.");
            resp.sendRedirect(req.getContextPath() + "/app/approvals");
            return;
        }

        String decision = value(req, "decision");
        if (!"approved".equals(decision) && !"rejected".equals(decision)) {
            Flash.error(req, "Invalid approval decision.");
            resp.sendRedirect(req.getContextPath() + "/app/approvals");
            return;
        }

        if ("registration".equals(action)) {
            eventDAO.decideRegistration(Integer.parseInt(value(req, "registrationId")), user, decision);
            Flash.success(req, "Event registration request " + decision + ".");
        } else {
            hourLogDAO.decide(Integer.parseInt(value(req, "logId")), user.getUserId(), decision, value(req, "remarks"));
            req.getSession().setAttribute("currentUser", userDAO.findById(user.getUserId()));
            Flash.success(req, "Hour claim " + decision + ".");
        }
        resp.sendRedirect(req.getContextPath() + "/app/approvals");
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
