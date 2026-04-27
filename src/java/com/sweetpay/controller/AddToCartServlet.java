package com.sweetpay.controller;

import com.sweetpay.dao.ProductDAO;
import com.sweetpay.model.CartItem;
import com.sweetpay.model.Product;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/add-to-cart"})
public class AddToCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        HttpSession session = request.getSession();
        ProductDAO dao = new ProductDAO();
        Product product = dao.getProductById(id);
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/products?error=not-found");
            return;
        }

        Integer availableStock = dao.getAvailableStock(id);
        if (availableStock != null && availableStock <= 0) {
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + id + "&status=out-of-stock");
            return;
        }

        Map<Integer, CartItem> cart = readCart(session);

        if (cart == null) {
            cart = new HashMap<>();
        }

        CartItem item = cart.get(id);
        int currentQuantity = item != null ? item.getQuantity() : 0;
        int nextQuantity = currentQuantity + 1;
        if (availableStock != null && nextQuantity > availableStock) {
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + id
                    + "&status=stock-limit&max=" + availableStock);
            return;
        }

        if (item != null) {
            item.setProduct(product);
            item.setQuantity(nextQuantity);
        } else {
            cart.put(id, new CartItem(product, 1));
        }

        session.setAttribute("cart", cart);

        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + id + "&status=success");
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
