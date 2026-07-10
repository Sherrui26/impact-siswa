package com.impactsiswa.servlet;

import com.impactsiswa.util.UploadStorage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@WebServlet("/app/event-images/*")
public class EventImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String requested = req.getPathInfo() == null ? "" : req.getPathInfo().replaceFirst("^/", "");
        Path fileName = Path.of(requested).getFileName();
        if (fileName == null || !fileName.toString().equals(requested)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path image = UploadStorage.eventDirectory().resolve(fileName).normalize();
        if (!Files.exists(image) || !Files.isRegularFile(image)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(image.getFileName().toString());
        resp.setContentType(contentType == null ? "application/octet-stream" : contentType);
        resp.setHeader("Cache-Control", "private, max-age=3600");
        Files.copy(image, resp.getOutputStream());
    }
}