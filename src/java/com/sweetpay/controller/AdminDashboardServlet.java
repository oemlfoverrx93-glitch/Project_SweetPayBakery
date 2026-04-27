package com.sweetpay.controller;

import com.sweetpay.dao.AdminDashboardDAO;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        AdminDashboardDAO dao = new AdminDashboardDAO();

        int totalProducts = dao.getTotalProducts();
        int totalOrders = dao.getTotalOrders();
        int totalUsers = dao.getTotalUsers();
        BigDecimal completedRevenue = dao.getCompletedRevenue();

        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("completedRevenue", completedRevenue);
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}
