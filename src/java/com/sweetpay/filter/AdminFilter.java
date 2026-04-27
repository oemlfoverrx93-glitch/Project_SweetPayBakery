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

@WebFilter(filterName = "AdminFilter", urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (!isAuthenticated(session)) {
            HttpSession writableSession = req.getSession(true);
            String redirect = buildRedirectTarget(req);
            writableSession.setAttribute("afterLoginRedirect", redirect);
            String encoded = URLEncoder.encode(redirect, StandardCharsets.UTF_8);
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + encoded);
            return;
        }

        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/home?error=admin-forbidden");
            return;
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
