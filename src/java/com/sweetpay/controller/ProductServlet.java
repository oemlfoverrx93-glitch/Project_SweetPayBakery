package com.sweetpay.controller;

import com.sweetpay.dao.ProductDAO;
import com.sweetpay.model.Category;
import com.sweetpay.model.Product;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
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
        String sort = trimToNull(request.getParameter("sort"));

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

        products = sortProducts(products, sort);

        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategory", selectedCategory);
        request.setAttribute("selectedSort", sort != null ? sort : "default");
        request.getRequestDispatcher("/views/web/product-list.jsp").forward(request, response);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private List<Product> sortProducts(List<Product> products, String sort) {
        List<Product> sortedProducts = new ArrayList<>(products);
        if ("price-asc".equals(sort)) {
            sortedProducts.sort(Comparator.comparing(this::displayPrice));
        } else if ("price-desc".equals(sort)) {
            sortedProducts.sort(Comparator.comparing(this::displayPrice).reversed());
        } else if ("name-asc".equals(sort)) {
            sortedProducts.sort(Comparator.comparing(
                    p -> p.getProductName() != null ? p.getProductName().toLowerCase() : ""));
        } else if ("sale".equals(sort)) {
            sortedProducts.sort(Comparator.comparing((Product p) -> hasSale(p) ? 0 : 1)
                    .thenComparing(this::displayPrice));
        }
        return sortedProducts;
    }

    private BigDecimal displayPrice(Product product) {
        if (product == null) {
            return BigDecimal.ZERO;
        }
        if (product.getSalePrice() != null && product.getSalePrice().compareTo(BigDecimal.ZERO) > 0) {
            return product.getSalePrice();
        }
        return product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO;
    }

    private boolean hasSale(Product product) {
        return product != null
                && product.getSalePrice() != null
                && product.getSalePrice().compareTo(BigDecimal.ZERO) > 0;
    }
}
