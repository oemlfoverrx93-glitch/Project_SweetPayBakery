package com.sweetpay.filter;

import com.sweetpay.util.AuthSessionUtil;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter(filterName = "AdminFilter", urlPatterns = {"/*"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        req.setCharacterEncoding("UTF-8");
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String path = req.getServletPath();
        if (path.startsWith("/views/") || path.endsWith(".jsp") && !"/index.jsp".equals(path)) {
            resp.sendError(404); return;
        }
        if (path.startsWith("/assets/") || path.startsWith("/payments/vnpay/")) {
            chain.doFilter(request,response); return;
        }
        // Refresh account status and role, so locking/reassigning an account takes effect immediately.
        Integer id = AuthSessionUtil.getUserId(session);
        if (id != null) {
            com.sweetpay.model.User fresh = new com.sweetpay.dao.UserDAO().findById(id);
            if (fresh == null || !fresh.isStatus()) {
                session.invalidate(); session = null;
            } else AuthSessionUtil.setAuthenticatedUser(session,fresh);
        }
        boolean adminArea=path.startsWith("/admin/");
        boolean storeArea=path.startsWith("/staff/");
        boolean driverArea=path.startsWith("/delivery/");
        if (!adminArea && !storeArea && !driverArea) { chain.doFilter(request,response); return; }
        resp.setHeader("Cache-Control", "no-store");

        if (!isAuthenticated(session)) {
            HttpSession writableSession = req.getSession(true);
            String redirect = buildRedirectTarget(req);
            writableSession.setAttribute("afterLoginRedirect", redirect);
            String encoded = URLEncoder.encode(redirect, StandardCharsets.UTF_8);
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + encoded);
            return;
        }

        String role=AuthSessionUtil.role(session);
        if (!isAdmin(session) && !(storeArea && "store_staff".equals(role)) && !(driverArea && "delivery_staff".equals(role))) {
            resp.sendError(403);
            return;
        }

        if ("POST".equalsIgnoreCase(req.getMethod()) && !com.sweetpay.util.CsrfUtil.isValid(req)) {
            resp.sendError(403); return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }

    private boolean isAuthenticated(HttpSession session) {
        return AuthSessionUtil.getUserId(session) != null;
    }

    private boolean isAdmin(HttpSession session) {
        return AuthSessionUtil.isAdmin(session);
    }

    private String buildRedirectTarget(HttpServletRequest req) {
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String target = uri;
        if (contextPath != null && !contextPath.isEmpty() && uri.startsWith(contextPath)) {
            target = uri.substring(contextPath.length());
        }

        String query = req.getQueryString();
        if (query != null && !query.trim().isEmpty()) {
            target = target + "?" + query;
        }
        return target;
    }
}
