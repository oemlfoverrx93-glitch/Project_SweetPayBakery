package com.sweetpay.util;

import com.sweetpay.model.User;
import javax.servlet.http.HttpSession;

public final class AuthSessionUtil {

    private AuthSessionUtil() {
    }

    public static void setAuthenticatedUser(HttpSession session, User user) {
        if (session == null || user == null) {
            return;
        }

        String roleName = user.getRoleName() == null ? "" : user.getRoleName().trim().toLowerCase();
        boolean isAdmin = "admin".equals(roleName);

        session.setAttribute("userId", user.getUserId());
        session.setAttribute("user", user);
        session.setAttribute("roleId", user.getRoleId());
        session.setAttribute("roleName", roleName);
        session.setAttribute("role", roleName);
        session.setAttribute("isAdmin", isAdmin);
        session.setAttribute("userFullName", user.getFullName());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userAvatar", user.getAvatarUrl());
    }

    public static void clear(HttpSession session) {
        if (session == null) {
            return;
        }
        session.removeAttribute("userId");
        session.removeAttribute("user");
        session.removeAttribute("roleId");
        session.removeAttribute("roleName");
        session.removeAttribute("role");
        session.removeAttribute("isAdmin");
        session.removeAttribute("userFullName");
        session.removeAttribute("userEmail");
        session.removeAttribute("userAvatar");
    }

    public static Integer getUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute("userId");
        return value instanceof Integer ? (Integer) value : null;
    }

    public static boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object value = session.getAttribute("isAdmin");
        if (value instanceof Boolean) {
            return (Boolean) value;
        }

        Object roleName = session.getAttribute("roleName");
        return roleName != null && "admin".equalsIgnoreCase(String.valueOf(roleName));
    }
}
