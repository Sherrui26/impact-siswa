package com.impactsiswa.servlet;

import com.impactsiswa.dao.AffiliationDAO;
import com.impactsiswa.model.Affiliation;
import com.impactsiswa.util.Flash;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class AffiliationServlet extends HttpServlet {
    private final AffiliationDAO affiliationDAO = new AffiliationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("activePage", "affiliations");
        req.setAttribute("affiliations", affiliationDAO.findAll());
        String edit = value(req, "edit");
        if (!edit.isBlank()) {
            req.setAttribute("editingAffiliation", affiliationDAO.findById(Integer.parseInt(edit)));
        }
        req.getRequestDispatcher("/WEB-INF/views/app/affiliations.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = value(req, "action");
        try {
            if ("delete".equals(action)) {
                affiliationDAO.delete(Integer.parseInt(value(req, "affiliationId")));
                Flash.success(req, "Faculty or club removed.");
            } else {
                String type = value(req, "type");
                if (!("faculty".equals(type) || "club".equals(type) || "unit".equals(type))) {
                    Flash.error(req, "Please choose a valid type.");
                    resp.sendRedirect(req.getContextPath() + "/app/affiliations");
                    return;
                }

                Affiliation affiliation = new Affiliation();
                String id = value(req, "affiliationId");
                if (!id.isBlank()) {
                    affiliation.setAffiliationId(Integer.parseInt(id));
                }
                affiliation.setName(value(req, "name"));
                affiliation.setType(type);
                affiliation.setActive("on".equals(req.getParameter("active")));
                affiliationDAO.save(affiliation);
                Flash.success(req, "Faculty or club saved.");
            }
        } catch (IllegalStateException e) {
            Flash.error(req, "Unable to save. The name may already exist for that type.");
        }
        resp.sendRedirect(req.getContextPath() + "/app/affiliations");
    }

    private String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
