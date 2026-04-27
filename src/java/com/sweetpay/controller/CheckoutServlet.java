package com.sweetpay.controller;

import com.sweetpay.model.CartItem;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = getLoggedInUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=login-required");
            return;
        }

        Map<Integer, CartItem> cart = getCart(session);

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        request.setAttribute("userId", userId);
        request.setAttribute("grandTotal", calculateGrandTotal(cart));
        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }

    @SuppressWarnings("unchecked")
    private Map<Integer, CartItem> getCart(HttpSession session) {
        return (Map<Integer, CartItem>) session.getAttribute("cart");
    }

    private BigDecimal calculateGrandTotal(Map<Integer, CartItem> cart) {
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

    private Integer getLoggedInUserId(HttpSession session) {
        Object userObj = session.getAttribute("userId");
        if (userObj instanceof Integer) {
            return (Integer) userObj;
        }
        return null;
    }
}
