package com.sweetpay.controller;

import com.sweetpay.dao.AdminDashboardDAO;
import com.sweetpay.model.CustomerSpending;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
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
        LocalDate today = LocalDate.now();
        LocalDate defaultStartDate = today.withDayOfMonth(1);
        LocalDate spendingStartDate = parseDateOrDefault(request.getParameter("startDate"), defaultStartDate);
        LocalDate spendingEndDate = parseDateOrDefault(request.getParameter("endDate"), today);

        if (spendingStartDate.isAfter(spendingEndDate)) {
            LocalDate originalStartDate = spendingStartDate;
            spendingStartDate = spendingEndDate;
            spendingEndDate = originalStartDate;
            request.setAttribute("spendingDateNotice", "Ngày bắt đầu lớn hơn ngày kết thúc nên hệ thống đã tự hoán đổi khoảng lọc.");
        }

        Timestamp startInclusive = Timestamp.valueOf(spendingStartDate.atStartOfDay());
        Timestamp endExclusive = Timestamp.valueOf(spendingEndDate.plusDays(1).atStartOfDay());
        List<CustomerSpending> topCustomerSpendings = dao.getTopCustomersBySpending(startInclusive, endExclusive, 10);

        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("completedRevenue", completedRevenue);
        request.setAttribute("spendingStartDate", spendingStartDate.toString());
        request.setAttribute("spendingEndDate", spendingEndDate.toString());
        request.setAttribute("topCustomerSpendings", topCustomerSpendings);
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    private LocalDate parseDateOrDefault(String value, LocalDate fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }

        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException ex) {
            return fallback;
        }
    }
}
