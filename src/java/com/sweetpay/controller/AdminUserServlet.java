package com.sweetpay.controller;

import com.sweetpay.dao.UserDAO;
import com.sweetpay.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = trimToEmpty(request.getParameter("q"));
        String status = normalizeStatusFilter(request.getParameter("status"));

        List<User> users = userDAO.getUsersForAdmin(keyword, status);
        request.setAttribute("users", users);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.getRequestDispatcher("/views/admin/manage-users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int userId;
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/users?updated=0");
            return;
        }

        String statusRaw = trimToEmpty(request.getParameter("newStatus"));
        boolean enabled = "active".equalsIgnoreCase(statusRaw);
        boolean updated = userDAO.updateUserStatus(userId, enabled);

        String q = trimToEmpty(request.getParameter("q"));
        String status = normalizeStatusFilter(request.getParameter("statusFilter"));
        String redirect = request.getContextPath() + "/admin/users?updated=" + (updated ? "1" : "0")
                + "&status=" + encode(status)
                + "&q=" + encode(q);
        response.sendRedirect(redirect);
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeStatusFilter(String value) {
        String normalized = trimToEmpty(value).toLowerCase();
        if ("active".equals(normalized) || "inactive".equals(normalized)) {
            return normalized;
        }
        return "all";
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
