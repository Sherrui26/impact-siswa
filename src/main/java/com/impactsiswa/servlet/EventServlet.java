package com.impactsiswa.servlet;

import com.impactsiswa.dao.CategoryDAO;
import com.impactsiswa.dao.EventDAO;
import com.impactsiswa.model.User;
import com.impactsiswa.model.VolunteerEvent;
import com.impactsiswa.util.Flash;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

@WebServlet({"/app/events", "/app/manage-events"})
public class EventServlet extends HttpServlet {
    private final EventDAO eventDAO = new EventDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        String page = req.getServletPath().contains("manage") ? "manage-events" : "events";
        req.setAttribute("activePage", page);
        req.setAttribute("events", eventDAO.findAll(user.getUserId()));
        req.setAttribute("categories", categoryDAO.findAll());

        String editId = req.getParameter("edit");
        if (editId != null) {
            req.setAttribute("editingEvent", eventDAO.findById(Integer.parseInt(editId)));
        }

        req.getRequestDispatcher("/WEB-INF/views/app/" + page + ".jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        String action = value(req, "action");

        try {
            if (user.isStudent() && !("join".equals(action) || "cancelJoin".equals(action))) {
                Flash.error(req, "Students can only join or cancel event registrations.");
                resp.sendRedirect(req.getContextPath() + "/app/events");
                return;
            }
            switch (action) {
                case "join" -> {
                    eventDAO.joinEvent(Integer.parseInt(value(req, "eventId")), user.getUserId());
                    Flash.success(req, "Join request submitted. A club leader or admin will review it.");
                    resp.sendRedirect(req.getContextPath() + "/app/events");
                }
                case "cancelJoin" -> {
                    eventDAO.cancelJoin(Integer.parseInt(value(req, "eventId")), user.getUserId());
                    Flash.success(req, "Event registration request cancelled.");
                    resp.sendRedirect(req.getContextPath() + "/app/events");
                }
                case "delete" -> {
                    eventDAO.delete(Integer.parseInt(value(req, "eventId")));
                    Flash.success(req, "Event deleted successfully.");
                    resp.sendRedirect(req.getContextPath() + "/app/manage-events");
                }
                default -> saveEvent(req, resp, user);
            }
        } catch (RuntimeException e) {
            Flash.error(req, "Unable to process event request: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/app/events");
        }
    }

    private void saveEvent(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        VolunteerEvent event = new VolunteerEvent();
        String eventId = value(req, "eventId");
        if (!eventId.isBlank()) {
            event.setEventId(Integer.parseInt(eventId));
        }
        event.setTitle(value(req, "title"));
        event.setDescription(value(req, "description"));
        event.setCatId(Integer.parseInt(value(req, "catId")));
        event.setEventDate(Date.valueOf(value(req, "eventDate")));
        event.setLocation(value(req, "location"));
        event.setHours(new BigDecimal(value(req, "hours")));
        event.setMaxVolunteers(Integer.parseInt(value(req, "maxVolunteers")));
        event.setStatus(value(req, "status").isBlank() ? "open" : value(req, "status"));
        event.setCreatedBy(user.getUserId());

        if (event.getEventId() > 0) {
            eventDAO.update(event);
            Flash.success(req, "Event updated successfully.");
        } else {
            eventDAO.create(event);
            Flash.success(req, "Event created successfully.");
        }
        resp.sendRedirect(req.getContextPath() + "/app/manage-events");
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
