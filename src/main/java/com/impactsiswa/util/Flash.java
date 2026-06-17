package com.impactsiswa.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class Flash {
    private Flash() {
    }

    public static void success(HttpServletRequest request, String message) {
        set(request, "success", message);
    }

    public static void error(HttpServletRequest request, String message) {
        set(request, "error", message);
    }

    private static void set(HttpServletRequest request, String key, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("flash_" + key, message);
    }
}
