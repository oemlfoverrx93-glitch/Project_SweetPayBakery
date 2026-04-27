package com.sweetpay.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ProductDetailLegacyServlet", urlPatterns = {"/product-detail-legacy"})
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id != null && !id.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + id.trim());
            return;
        }
        response.sendRedirect(request.getContextPath() + "/products");
    }
}
