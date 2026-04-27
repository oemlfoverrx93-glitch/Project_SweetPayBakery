package com.sweetpay.controller;

import com.sweetpay.dao.ProductDAO;
import com.sweetpay.model.CartItem;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "UpdateCartQuantityServlet", urlPatterns = {"/update-cart-quantity"})
public class UpdateCartQuantityServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = readCart(session);
        CartItem item = cart.get(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        int quantity = item.getQuantity();
        String quantityParam = request.getParameter("quantity");
        if (quantityParam != null) {
            try {
                quantity = Integer.parseInt(quantityParam);
            } catch (NumberFormatException ignored) {
                quantity = item.getQuantity();
            }
        }

        String action = request.getParameter("action");
        int nextQuantity;
        if ("increase".equals(action)) {
            nextQuantity = item.getQuantity() + 1;
        } else if ("decrease".equals(action)) {
            nextQuantity = item.getQuantity() - 1;
        } else {
            nextQuantity = quantity;
        }

        ProductDAO productDAO = new ProductDAO();
        Integer availableStock = productDAO.getAvailableStock(id);

        if (availableStock != null && availableStock <= 0) {
            cart.remove(id);
            session.setAttribute("cart", cart);
            response.sendRedirect(request.getContextPath() + "/cart?status=out-of-stock");
            return;
        }

        if (nextQuantity <= 0) {
            cart.remove(id);
            session.setAttribute("cart", cart);
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if (availableStock != null && nextQuantity > availableStock) {
            item.setQuantity(availableStock);
            session.setAttribute("cart", cart);
            response.sendRedirect(request.getContextPath() + "/cart?status=stock-limit&max=" + availableStock);
            return;
        }

        item.setQuantity(nextQuantity);
        session.setAttribute("cart", cart);
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private Map<Integer, CartItem> readCart(HttpSession session) {
        Object value = session.getAttribute("cart");
        if (!(value instanceof Map<?, ?>)) {
            return new HashMap<>();
        }

        Map<?, ?> rawMap = (Map<?, ?>) value;
        Map<Integer, CartItem> result = new HashMap<>();
        for (Map.Entry<?, ?> entry : rawMap.entrySet()) {
            Object key = entry.getKey();
            Object cartItem = entry.getValue();
            if (key instanceof Integer && cartItem instanceof CartItem) {
                result.put((Integer) key, (CartItem) cartItem);
            }
        }
        return result;
    }
}
