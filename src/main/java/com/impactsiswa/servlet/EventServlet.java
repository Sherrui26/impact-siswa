package com.impactsiswa.servlet;

import com.impactsiswa.dao.CategoryDAO;
import com.impactsiswa.dao.EventDAO;
import com.impactsiswa.model.User;
import com.impactsiswa.model.VolunteerEvent;
import com.impactsiswa.util.Flash;
import com.impactsiswa.util.UploadStorage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@WebServlet({"/app/events", "/app/manage-events"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 7 * 1024 * 1024)
public class EventServlet extends HttpServlet {
    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of("image/jpeg", "image/png", "image/webp", "image/gif");

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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
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

    private void saveEvent(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException, ServletException {
        VolunteerEvent event = new VolunteerEvent();
        String eventId = value(req, "eventId");
        boolean isEdit = !eventId.isBlank();
        if (isEdit) {
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

        // Preserve the existing image on edit unless a new one is uploaded or removal is requested.
        String existingImage = null;
        if (isEdit) {
            VolunteerEvent current = eventDAO.findById(event.getEventId());
            existingImage = current == null ? null : current.getImagePath();
        }

        String uploaded = saveEventImage(req);
        if (uploaded == null && hasSubmittedFile(req, "image")) {
            Flash.error(req, "Please upload a JPG, PNG, WEBP, or GIF image under 5 MB.");
            resp.sendRedirect(req.getContextPath() + "/app/manage-events" + (isEdit ? "?edit=" + event.getEventId() : ""));
            return;
        }

        boolean removeImage = "true".equals(value(req, "removeImage"));
        if (uploaded != null) {
            event.setImagePath(uploaded);
            deleteEventImage(existingImage);
        } else if (removeImage) {
            event.setImagePath(null);
            deleteEventImage(existingImage);
        } else {
            event.setImagePath(existingImage);
        }

        if (event.getEventId() > 0) {
            eventDAO.update(event);
            Flash.success(req, "Event updated successfully.");
        } else {
            eventDAO.create(event);
            Flash.success(req, "Event created successfully.");
        }
        resp.sendRedirect(req.getContextPath() + "/app/manage-events");
    }

    private boolean hasSubmittedFile(HttpServletRequest req, String fieldName) throws IOException, ServletException {
        Part part = req.getPart(fieldName);
        return part != null && part.getSize() > 0;
    }

    private String saveEventImage(HttpServletRequest req) throws IOException, ServletException {
        Part part = req.getPart("image");
        if (part == null || part.getSize() == 0) {
            return null;
        }

        String contentType = part.getContentType() == null ? "" : part.getContentType().toLowerCase(Locale.ROOT);
        if (!ALLOWED_IMAGE_TYPES.contains(contentType)) {
            return null;
        }

        String extension = switch (contentType) {
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            case "image/gif" -> ".gif";
            default -> ".jpg";
        };

        // Store a generated filename only; never trust or expose the uploader's original file path/name.
        String fileName = "event-" + UUID.randomUUID() + extension;
        Path uploadDir = UploadStorage.eventDirectory();
        Files.createDirectories(uploadDir);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, uploadDir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
        }
        return fileName;
    }

    private void deleteEventImage(String fileName) {
        if (fileName == null || fileName.isBlank()) {
            return;
        }
        try {
            Path stored = Path.of(fileName).getFileName();
            if (stored != null) {
                Files.deleteIfExists(UploadStorage.eventDirectory().resolve(stored));
            }
        } catch (IOException ignored) {
            // Best-effort cleanup; a leftover file is not fatal.
        }
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
