package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.model.Order;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "OrderHistoryServlet", urlPatterns = {"/order-history"})
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = getLoggedInUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=login-required");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByUserId(userId);

        request.setAttribute("orders", orders);
        request.setAttribute("userId", userId);
        request.getRequestDispatcher("/views/web/order-history.jsp").forward(request, response);
    }

    private Integer getLoggedInUserId(HttpSession session) {
        Object userObj = session.getAttribute("userId");
        if (userObj instanceof Integer) {
            return (Integer) userObj;
        }
        return null;
    }
}
