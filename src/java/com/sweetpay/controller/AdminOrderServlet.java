package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.dao.PaymentDAO;
import com.sweetpay.model.Order;
import com.sweetpay.model.Payment;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders", "/admin/order/detail"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/order/detail".equals(path)) {
            showOrderDetail(request, response);
            return;
        }
        showOrderList(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?updated=0");
            return;
        }

        String orderStatus = request.getParameter("orderStatus");
        String paymentStatus = request.getParameter("paymentStatus");
        boolean updated = orderDAO.updateStatusesForAdmin(orderId, orderStatus, paymentStatus);

        String from = trimToEmpty(request.getParameter("from"));
        if ("detail".equalsIgnoreCase(from)) {
            response.sendRedirect(request.getContextPath() + "/admin/order/detail?id=" + orderId + "&updated=" + (updated ? "1" : "0"));
            return;
        }

        String redirect = request.getContextPath() + "/admin/orders?updated=" + (updated ? "1" : "0")
                + "&orderStatus=" + encode(defaultFilterValue(request.getParameter("orderStatusFilter")))
                + "&paymentStatus=" + encode(defaultFilterValue(request.getParameter("paymentStatusFilter")))
                + "&q=" + encode(trimToEmpty(request.getParameter("q")));
        response.sendRedirect(redirect);
    }

    private void showOrderList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderStatus = defaultFilterValue(request.getParameter("orderStatus"));
        String paymentStatus = defaultFilterValue(request.getParameter("paymentStatus"));
        String keyword = trimToEmpty(request.getParameter("q"));

        List<Order> orders = orderDAO.getAllOrdersForAdmin(orderStatus, paymentStatus, keyword);
        request.setAttribute("orders", orders);
        request.setAttribute("selectedOrderStatus", orderStatus);
        request.setAttribute("selectedPaymentStatus", paymentStatus);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/views/admin/manage-orders.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=invalid-id");
            return;
        }

        Order order = orderDAO.getOrderByIdForAdmin(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=not-found");
            return;
        }

        Payment payment = paymentDAO.getByOrderId(orderId);
        request.setAttribute("order", order);
        request.setAttribute("payment", payment);
        request.getRequestDispatcher("/views/admin/order-detail.jsp").forward(request, response);
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String defaultFilterValue(String value) {
        String trimmed = trimToEmpty(value);
        return trimmed.isEmpty() ? "all" : trimmed;
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
