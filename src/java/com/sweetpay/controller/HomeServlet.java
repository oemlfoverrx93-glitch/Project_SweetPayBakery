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

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO productDAO = new ProductDAO();
        List<Product> products = productDAO.getAllProducts();
        List<Category> categories = productDAO.getActiveCategories();
        int size = products != null ? products.size() : 0;
        System.out.println("[HomeServlet] /home products fetched: " + size);

        // Keep both names to avoid JSP/Servlet attribute mismatch during migration.
        request.setAttribute("products", products);
        request.setAttribute("productList", products);
        request.setAttribute("categories", categories);
        request.setAttribute("navCategories", categories);
        request.setAttribute("navProducts", products);
        request.getRequestDispatcher("/views/web/home.jsp").forward(request, response);
    }
}
