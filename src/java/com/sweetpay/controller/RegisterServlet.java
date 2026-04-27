package com.sweetpay.controller;

import com.sweetpay.dao.UserDAO;
import java.io.IOException;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{10,11}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String fullName = trimToEmpty(request.getParameter("fullName"));
        String email = trimToEmpty(request.getParameter("email"));
        String phone = trimToEmpty(request.getParameter("phone"));
        String password = trimToEmpty(request.getParameter("password"));
        String confirmPassword = trimToEmpty(request.getParameter("confirmPassword"));

        // Validate required fields
        if (fullName.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            request.setAttribute("error", "Email không đúng định dạng.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Validate phone format if provided
        if (!phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches()) {
            request.setAttribute("error", "Số điện thoại không hợp lệ (phải từ 10-11 số).");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Validate password length
        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Validate password confirmation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (userDAO.isEmailExists(email)) {
            request.setAttribute("error", "Email đã tồn tại trong hệ thống.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
            return;
        }

        // Register user
        boolean success = userDAO.registerUser(fullName, email, phone, password);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?register=success");
        } else {
            request.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại.");
            request.getRequestDispatcher("/views/web/register.jsp").forward(request, response);
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
