package com.sweetpay.util;

import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public final class CsrfUtil {

    public static final String PARAM_NAME = "csrfToken";
    private static final String SESSION_KEY = "csrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfUtil() {
    }

    public static String getToken(HttpSession session) {
        if (session == null) {
            return "";
        }

        Object existing = session.getAttribute(SESSION_KEY);
        if (existing instanceof String && !((String) existing).isEmpty()) {
            return (String) existing;
        }

        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(SESSION_KEY, token);
        return token;
    }

    public static String getToken(Object session) {
        if (session == null) {
            return "";
        }
        if (session instanceof HttpSession) {
            return getToken((HttpSession) session);
        }

        try {
            Object existing = session.getClass()
                    .getMethod("getAttribute", String.class)
                    .invoke(session, SESSION_KEY);
            if (existing instanceof String && !((String) existing).isEmpty()) {
                return (String) existing;
            }

            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.getClass()
                    .getMethod("setAttribute", String.class, Object.class)
                    .invoke(session, SESSION_KEY, token);
            return token;
        } catch (ReflectiveOperationException ex) {
            return "";
        }
    }

    public static boolean isValid(HttpServletRequest request) {
        if (request == null) {
            return false;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        Object sessionToken = session.getAttribute(SESSION_KEY);
        String requestToken = request.getParameter(PARAM_NAME);
        return sessionToken instanceof String
                && requestToken != null
                && ((String) sessionToken).equals(requestToken);
    }
}
