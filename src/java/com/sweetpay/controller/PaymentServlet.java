package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.dao.PaymentDAO;
import com.sweetpay.dao.StoreBankAccountDAO;
import com.sweetpay.model.Order;
import com.sweetpay.model.Payment;
import com.sweetpay.model.StoreBankAccount;
import com.sweetpay.util.AuthSessionUtil;
import com.sweetpay.util.CsrfUtil;
import com.sweetpay.util.VietQRUtil;
import java.io.IOException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment"})
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        if (!canAccessOrder(request.getSession(false), order)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        StoreBankAccountDAO accountDAO = new StoreBankAccountDAO();
        StoreBankAccount account = accountDAO.getDefaultAccount();

        if (account == null) {
            // Fallback nếu bảng store_bank_account chưa được tạo
            account = new StoreBankAccount();
            account.setBankName("Ngân hàng Quân đội (MB Bank)");
            account.setAccountNumber("240220060903");
            account.setAccountHolder("Nguyễn Thị Tuyết Mai");
            account.setBinCode("970422");
        }

        String amountStr = "0";
        if (order.getTotalAmount() != null) {
            amountStr = String.format("%.0f", order.getTotalAmount());
        }

        String qrText = VietQRUtil.generateEMVCoPayload(
                account.getBinCode(), 
                account.getAccountNumber(), 
                amountStr, 
                order.getOrderCode()
        );

        request.setAttribute("qrText", qrText);
        request.setAttribute("amount", amountStr);
        request.setAttribute("orderCode", order.getOrderCode());
        request.setAttribute("account", account);
        request.setAttribute("orderId", orderId);

        request.getRequestDispatcher("/views/web/payment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!CsrfUtil.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        if (!canAccessOrder(request.getSession(false), order)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        PaymentDAO paymentDAO = new PaymentDAO();
        boolean updated = paymentDAO.updatePaymentStatusByOrderId(orderId, "paid");
        if (!updated) {
            Payment payment = new Payment();
            payment.setOrderId(orderId);
            payment.setPaymentMethod("BANK_TRANSFER");
            payment.setAmount(order.getTotalAmount());
            payment.setPaymentStatus("paid");
            payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
            updated = paymentDAO.insertPayment(payment) > 0;
        }

        if (updated) {
            response.sendRedirect(request.getContextPath() + "/order-success?id=" + orderId + "&payment=confirmed");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/payment?orderId=" + orderId + "&status=confirm-failed");
    }

    private Integer parseOrderId(HttpServletRequest request) {
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            orderIdStr = request.getParameter("id");
        }
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            return null;
        }

        try {
            return Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean canAccessOrder(HttpSession session, Order order) {
        if (order == null) {
            return false;
        }
        if (AuthSessionUtil.isAdmin(session)) {
            return true;
        }
        Integer userId = AuthSessionUtil.getUserId(session);
        return userId != null && userId == order.getUserId();
    }
}
