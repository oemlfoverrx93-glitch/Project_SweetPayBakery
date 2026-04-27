package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.model.Order;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "OrderSuccessServlet", urlPatterns = {"/order-success"})
public class OrderSuccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = getLoggedInUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=login-required");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        Order order = new OrderDAO().getOrderById(orderId);
        if (order == null || order.getUserId() != userId) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/web/order-success.jsp").forward(request, response);
    }

    private Integer getLoggedInUserId(HttpSession session) {
        Object userObj = session.getAttribute("userId");
        if (userObj instanceof Integer) {
            return (Integer) userObj;
        }
        return null;
    }
}
