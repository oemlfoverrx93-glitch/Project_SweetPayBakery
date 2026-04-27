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

@WebServlet(name = "ProductServlet", urlPatterns = {"/products", "/product-detail"})
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO productDAO = new ProductDAO();
        List<Category> navCategories = productDAO.getActiveCategories();
        List<Product> navProducts = productDAO.getAllProducts();
        request.setAttribute("navCategories", navCategories);
        request.setAttribute("navProducts", navProducts);

        String path = request.getServletPath();

        if ("/product-detail".equals(path)) {
            int id;
            try {
                id = Integer.parseInt(request.getParameter("id"));
            } catch (NumberFormatException ex) {
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            Product product = productDAO.getProductById(id);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/products?error=not-found");
                return;
            }

            request.setAttribute("product", product);
            request.getRequestDispatcher("/views/web/product-detail.jsp").forward(request, response);
            return;
        }

        String categoryRaw = request.getParameter("categoryId");
        String keyword = trimToNull(request.getParameter("q"));

        List<Product> products;
        Integer selectedCategory = null;

        if (keyword != null) {
            products = productDAO.searchProducts(keyword);
        } else if (categoryRaw != null && !categoryRaw.trim().isEmpty()) {
            try {
                selectedCategory = Integer.parseInt(categoryRaw);
                products = productDAO.getProductsByCategory(selectedCategory);
            } catch (NumberFormatException ex) {
                products = productDAO.getAllProducts();
            }
        } else {
            products = productDAO.getAllProducts();
        }

        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategory", selectedCategory);
        request.getRequestDispatcher("/views/web/product-list.jsp").forward(request, response);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
