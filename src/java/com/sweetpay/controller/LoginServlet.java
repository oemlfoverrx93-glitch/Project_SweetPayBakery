package com.sweetpay.controller;

import com.sweetpay.dao.UserDAO;
import com.sweetpay.model.User;
import com.sweetpay.util.AuthSessionUtil;
import com.sweetpay.util.GoogleAuthService;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final GoogleAuthService googleAuthService = new GoogleAuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (AuthSessionUtil.getUserId(session) != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        request.setAttribute("googleClientId", googleAuthService.getGoogleClientId());
        request.setAttribute("redirect", sanitizeRedirect(request.getParameter("redirect")));
        request.getRequestDispatcher("/views/web/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = trimToEmpty(request.getParameter("email"));
        String password = trimToEmpty(request.getParameter("password"));
        String redirect = sanitizeRedirect(request.getParameter("redirect"));

        if (email.isEmpty() || password.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login?error=missing&redirect=" + encode(redirect));
            return;
        }

        User user = userDAO.authenticateLocal(email, password);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=invalid&redirect=" + encode(redirect));
            return;
        }

        HttpSession session = request.getSession(true);
        AuthSessionUtil.setAuthenticatedUser(session, user);
        userDAO.updateLastLogin(user.getUserId());

        response.sendRedirect(request.getContextPath() + resolvePostLoginPath(session, redirect));
    }

    private String resolvePostLoginPath(HttpSession session, String redirect) {
        String safe = sanitizeRedirect(redirect);
        if (!safe.isEmpty()) {
            return safe;
        }

        Object fromFilter = session.getAttribute("afterLoginRedirect");
        if (fromFilter != null) {
            session.removeAttribute("afterLoginRedirect");
            return sanitizeRedirect(String.valueOf(fromFilter));
        }
        return "/home";
    }

    private String sanitizeRedirect(String redirect) {
        if (redirect == null) {
            return "";
        }
        String value = redirect.trim();
        if (value.isEmpty()) {
            return "";
        }
        if (!value.startsWith("/")) {
            return "";
        }
        if (value.startsWith("//") || value.contains("://")) {
            return "";
        }
        return value;
    }

    private String trimToEmpty(String input) {
        return input == null ? "" : input.trim();
    }

    private String encode(String value) {
        String safe = sanitizeRedirect(value);
        return safe.isEmpty() ? "" : URLEncoder.encode(safe, StandardCharsets.UTF_8);
    }
}
