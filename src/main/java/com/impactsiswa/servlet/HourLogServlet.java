package com.impactsiswa.servlet;

import com.impactsiswa.dao.EventDAO;
import com.impactsiswa.dao.HourLogDAO;
import com.impactsiswa.model.User;
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
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@WebServlet("/app/hours")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 7 * 1024 * 1024)
public class HourLogServlet extends HttpServlet {
    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of("image/jpeg", "image/png", "image/webp", "image/gif");

    private final EventDAO eventDAO = new EventDAO();
    private final HourLogDAO hourLogDAO = new HourLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        req.setAttribute("activePage", "hours");
        req.setAttribute("events", eventDAO.findApprovedForClaim(user.getUserId()));
        req.setAttribute("logs", hourLogDAO.findByUser(user.getUserId()));
        req.getRequestDispatcher("/WEB-INF/views/app/hours.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!user.isStudent()) {
            Flash.error(req, "Only students can submit volunteer hour claims.");
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
            return;
        }

        String action = value(req, "action");
        if ("cancel".equals(action)) {
            hourLogDAO.cancelPending(Integer.parseInt(value(req, "logId")), user.getUserId());
            Flash.success(req, "Pending hour claim cancelled.");
        } else {
            BigDecimal hours = new BigDecimal(value(req, "hoursClaimed"));
            int eventId = Integer.parseInt(value(req, "eventId"));
            if (hours.compareTo(BigDecimal.ZERO) <= 0) {
                Flash.error(req, "Hours claimed must be greater than zero.");
            } else if (!eventDAO.hasApprovedRegistration(eventId, user.getUserId())) {
                Flash.error(req, "You can only submit hours for approved event registrations.");
            } else if (hourLogDAO.hasPendingOrApprovedClaim(user.getUserId(), eventId)) {
                Flash.error(req, "You already have a pending or approved hour claim for this event.");
            } else {
                String proofImage = saveProofImage(req, user.getUserId());
                if (proofImage == null && hasSubmittedFile(req, "proofImage")) {
                    Flash.error(req, "Please upload a JPG, PNG, WEBP, or GIF image under 5 MB.");
                    resp.sendRedirect(req.getContextPath() + "/app/hours");
                    return;
                }
                hourLogDAO.create(user.getUserId(), eventId, hours, value(req, "evidence"), proofImage);
                Flash.success(req, "Hour claim submitted for approval.");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/app/hours");
    }

    private boolean hasSubmittedFile(HttpServletRequest req, String fieldName) throws IOException, ServletException {
        Part part = req.getPart(fieldName);
        return part != null && part.getSize() > 0;
    }

    private String saveProofImage(HttpServletRequest req, int userId) throws IOException, ServletException {
        Part part = req.getPart("proofImage");
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

        // Store a generated filename only; never trust or expose the student's original file path/name.
        String fileName = "proof-" + userId + "-" + UUID.randomUUID() + extension;
        Path uploadDir = UploadStorage.proofDirectory();
        Files.createDirectories(uploadDir);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, uploadDir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
        }
        return fileName;
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
