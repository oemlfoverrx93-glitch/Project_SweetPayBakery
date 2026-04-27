package com.sweetpay.controller;

import com.sweetpay.dao.OrderDAO;
import com.sweetpay.dao.ProductDAO;
import com.sweetpay.dao.VoucherDAO;
import com.sweetpay.dao.VoucherDAO.VoucherValidationResult;
import com.sweetpay.model.CartItem;
import com.sweetpay.model.Order;
import com.sweetpay.model.OrderDetail;
import com.sweetpay.model.Payment;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "PlaceOrderServlet", urlPatterns = {"/place-order"})
public class PlaceOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = getCart(session);

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?error=empty-cart");
            return;
        }

        Integer userId = getLoggedInUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=login-required");
            return;
        }

        String recipientName = normalize(request.getParameter("recipientName"));
        String recipientPhone = normalize(request.getParameter("recipientPhone"));
        String shippingAddress = normalize(request.getParameter("shippingAddress"));
        String receiveMethod = normalizeReceiveMethod(request.getParameter("receiveMethod"));
        String note = normalize(request.getParameter("note"));
        String paymentMethod = normalizePaymentMethod(request.getParameter("paymentMethod"));
        String voucherCode = normalize(request.getParameter("voucherCode"));

        if (recipientName == null || recipientPhone == null || shippingAddress == null) {
            forwardCheckoutWithError(request, response, userId, calculateTotal(cart), voucherCode,
                    "Please fill all required fields.");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        List<OrderDetail> details = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : cart.values()) {
            if (item == null || item.getProduct() == null || item.getQuantity() <= 0) {
                continue;
            }

            int productId = item.getProduct().getProductId();
            int quantity = item.getQuantity();
            Integer availableStock = productDAO.getAvailableStock(productId);
            if (availableStock != null && quantity > availableStock) {
                String productName = item.getProduct().getProductName() != null
                        ? item.getProduct().getProductName()
                        : "This product";
                forwardCheckoutWithError(request, response, userId, calculateTotal(cart), voucherCode,
                        productName + " only has " + availableStock + " item(s) left in stock.");
                return;
            }

            BigDecimal unitPrice = item.getProduct().getSalePrice() != null
                    ? item.getProduct().getSalePrice()
                    : item.getProduct().getPrice();
            if (unitPrice == null) {
                unitPrice = BigDecimal.ZERO;
            }

            OrderDetail detail = new OrderDetail();
            detail.setProductId(productId);
            detail.setQuantity(quantity);
            detail.setUnitPrice(unitPrice);
            details.add(detail);

            subtotal = subtotal.add(unitPrice.multiply(BigDecimal.valueOf(quantity)));
        }

        if (details.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?error=invalid-cart");
            return;
        }

        BigDecimal discountAmount = BigDecimal.ZERO;
        Integer voucherId = null;

        if (voucherCode != null) {
            VoucherValidationResult voucherValidation = new VoucherDAO().validateVoucher(voucherCode, subtotal);
            if (!voucherValidation.isValid()) {
                forwardCheckoutWithError(request, response, userId, subtotal, voucherCode,
                        voucherValidation.getMessage());
                return;
            }

            voucherId = voucherValidation.getVoucherId();
            discountAmount = voucherValidation.getDiscountAmount();
            voucherCode = voucherValidation.getVoucherCode();
        }

        BigDecimal shippingFee = BigDecimal.ZERO;
        BigDecimal totalAmount = subtotal.subtract(discountAmount).add(shippingFee);
        if (totalAmount.compareTo(BigDecimal.ZERO) < 0) {
            totalAmount = BigDecimal.ZERO;
        }

        Order order = new Order();
        order.setUserId(userId);
        order.setVoucherId(voucherId);
        order.setRecipientName(recipientName);
        order.setRecipientPhone(recipientPhone);
        order.setShippingAddress(shippingAddress);
        order.setReceiveMethod(receiveMethod);
        order.setSubtotal(subtotal);
        order.setDiscountAmount(discountAmount);
        order.setShippingFee(shippingFee);
        order.setTotalAmount(totalAmount);
        order.setOrderStatus("pending");
        order.setPaymentStatus("unpaid");
        order.setNote(note);
        order.setOrderDate(new Timestamp(System.currentTimeMillis()));

        Payment payment = new Payment();
        payment.setPaymentMethod(paymentMethod);
        payment.setAmount(totalAmount);
        payment.setPaymentStatus("COD".equals(paymentMethod) ? "unpaid" : "pending");

        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.placeOrder(order, details, payment);

        if (orderId > 0) {
            session.removeAttribute("cart");
            response.sendRedirect(request.getContextPath() + "/order-success?id=" + orderId);
            return;
        }

        forwardCheckoutWithError(request, response, userId, totalAmount, voucherCode,
                "Place order failed. Please try again.");
    }

    @SuppressWarnings("unchecked")
    private Map<Integer, CartItem> getCart(HttpSession session) {
        return (Map<Integer, CartItem>) session.getAttribute("cart");
    }

    private Integer getLoggedInUserId(HttpSession session) {
        Object userObj = session.getAttribute("userId");
        if (userObj instanceof Integer) {
            return (Integer) userObj;
        }
        return null;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeReceiveMethod(String value) {
        String normalized = normalize(value);
        if ("pickup".equalsIgnoreCase(normalized)) {
            return "pickup";
        }
        return "delivery";
    }

    private String normalizePaymentMethod(String value) {
        String normalized = normalize(value);
        if ("BANK_TRANSFER".equalsIgnoreCase(normalized)) {
            return "BANK_TRANSFER";
        }
        if ("MOMO".equalsIgnoreCase(normalized)) {
            return "MOMO";
        }
        if ("VNPAY".equalsIgnoreCase(normalized)) {
            return "VNPAY";
        }
        return "COD";
    }

    private BigDecimal calculateTotal(Map<Integer, CartItem> cart) {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cart.values()) {
            if (item == null || item.getProduct() == null || item.getQuantity() <= 0) {
                continue;
            }
            BigDecimal unitPrice = item.getProduct().getSalePrice() != null
                    ? item.getProduct().getSalePrice()
                    : item.getProduct().getPrice();
            if (unitPrice == null) {
                unitPrice = BigDecimal.ZERO;
            }
            total = total.add(unitPrice.multiply(BigDecimal.valueOf(item.getQuantity())));
        }
        return total;
    }

    private void forwardCheckoutWithError(HttpServletRequest request,
                                          HttpServletResponse response,
                                          int userId,
                                          BigDecimal grandTotal,
                                          String voucherCode,
                                          String error) throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("grandTotal", grandTotal != null ? grandTotal : BigDecimal.ZERO);
        request.setAttribute("userId", userId);
        request.setAttribute("voucherCode", voucherCode);
        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }
}
