package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.dao.PaymentDAO;
import com.sweetpay.model.Order;
import com.sweetpay.model.Payment;
import com.sweetpay.util.AuthSessionUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "OrderDetailServlet", urlPatterns = {"/order-detail"})
public class OrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        HttpSession session = request.getSession(false);
        Integer userId = AuthSessionUtil.getUserId(session);
        boolean isAdmin = AuthSessionUtil.isAdmin(session);
        if (!isAdmin && (userId == null || order.getUserId() != userId)) {
            response.sendRedirect(request.getContextPath() + "/order-history?error=forbidden");
            return;
        }

        Payment payment = new PaymentDAO().getPaymentByOrderId(orderId);
        request.setAttribute("order", order);
        request.setAttribute("payment", payment);
        request.getRequestDispatcher("/views/web/order-detail.jsp").forward(request, response);
    }
}
