package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.dao.StoreBankAccountDAO;
import com.sweetpay.model.Order;
import com.sweetpay.model.StoreBankAccount;
import com.sweetpay.util.VietQRUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment"})
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/home");
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
}
