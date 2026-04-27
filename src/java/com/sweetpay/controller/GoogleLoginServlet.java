package com.sweetpay.controller;

import com.sweetpay.dao.UserDAO;
import com.sweetpay.model.User;
import com.sweetpay.util.AuthSessionUtil;
import com.sweetpay.util.GoogleAuthService;
import com.sweetpay.util.GoogleAuthService.GoogleIdTokenPayload;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/google-login"})
public class GoogleLoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final GoogleAuthService googleAuthService = new GoogleAuthService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String redirect = sanitizeRedirect(request.getParameter("redirect"));
        String credential = firstNonBlank(request.getParameter("credential"), request.getParameter("idToken"));

        if (credential == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=google-missing&redirect=" + encode(redirect));
            return;
        }

        GoogleIdTokenPayload payload = googleAuthService.verifyIdToken(credential);
        if (payload == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=google-invalid&redirect=" + encode(redirect));
            return;
        }

        User user = findOrCreateUser(payload);
        if (user == null || !user.isStatus()) {
            response.sendRedirect(request.getContextPath() + "/login?error=google-user&redirect=" + encode(redirect));
            return;
        }

        HttpSession session = request.getSession(true);
        AuthSessionUtil.setAuthenticatedUser(session, user);
        userDAO.updateLastLogin(user.getUserId());

        response.sendRedirect(request.getContextPath() + resolvePostLoginPath(session, redirect));
    }

    private User findOrCreateUser(GoogleIdTokenPayload payload) {
        User user = userDAO.findByGoogleSub(payload.getSub());
        if (user != null) {
            return user;
        }

        User byEmail = userDAO.findByEmail(payload.getEmail());
        if (byEmail != null) {
            boolean linked = userDAO.linkGoogleAccount(
                    byEmail.getUserId(),
                    payload.getSub(),
                    payload.getPicture(),
                    payload.isEmailVerified()
            );
            return linked ? userDAO.findById(byEmail.getUserId()) : byEmail;
        }

        return userDAO.createGoogleUser(
                payload.getName(),
                payload.getEmail(),
                payload.getSub(),
                payload.getPicture(),
                payload.isEmailVerified()
        );
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

    private String firstNonBlank(String a, String b) {
        if (a != null && !a.trim().isEmpty()) {
            return a.trim();
        }
        if (b != null && !b.trim().isEmpty()) {
            return b.trim();
        }
        return null;
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

    private String encode(String value) {
        String safe = sanitizeRedirect(value);
        return safe.isEmpty() ? "" : URLEncoder.encode(safe, StandardCharsets.UTF_8);
    }
}
