package com.sweetpay.controller;

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

@WebServlet(name = "RemoveFromCartServlet", urlPatterns = {"/remove-from-cart"})
public class RemoveFromCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. Parse product id from query string
            int id = Integer.parseInt(request.getParameter("id"));
             
            // 2. Read cart from session
            HttpSession session = request.getSession();
            Map<Integer, CartItem> cart = readCart(session);
            
            // 3. Remove item if present
            if (cart != null && cart.containsKey(id)) {
                cart.remove(id);
                // Save updated cart
                session.setAttribute("cart", cart);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // 4. Redirect back to cart page
        response.sendRedirect("cart");
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
