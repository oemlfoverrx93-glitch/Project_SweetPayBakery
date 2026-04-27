package com.sweetpay.controller;

import com.sweetpay.dao.ProductDAO;
import com.sweetpay.model.Category;
import com.sweetpay.model.Product;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AboutServlet", urlPatterns = {"/about"})
public class AboutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO productDAO = new ProductDAO();
        List<Category> navCategories = productDAO.getActiveCategories();
        List<Product> navProducts = productDAO.getAllProducts();

        request.setAttribute("navCategories", navCategories);
        request.setAttribute("navProducts", navProducts);
        request.getRequestDispatcher("/views/web/about.jsp").forward(request, response);
    }
}
