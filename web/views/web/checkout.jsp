<%@page import="com.sweetpay.model.CartItem"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <h2 class="mb-4">Thanh toán</h2>

    <%
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        BigDecimal grandTotal = (BigDecimal) request.getAttribute("grandTotal");
        if (grandTotal == null) {
            grandTotal = BigDecimal.ZERO;
        }
        Object userIdObj = request.getAttribute("userId");
        Integer userId = (userIdObj instanceof Integer) ? (Integer) userIdObj : null;

        String error = (String) request.getAttribute("error");
        String voucherCode = (String) request.getAttribute("voucherCode");
        if (voucherCode == null) {
            voucherCode = request.getParameter("voucherCode");
        }
    %>

    <% if (error != null) { %>
    <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <% if (cart == null || cart.isEmpty()) { %>
    <div class="alert alert-warning">
        Giỏ hàng đang trống. <a href="<%=request.getContextPath()%>/home">Quay về trang chủ</a>
    </div>
    <% } else { %>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="card-title mb-3">Thông tin nhận hàng</h5>
                    <form action="<%=request.getContextPath()%>/place-order" method="post">
                        <input type="hidden" name="userId" value="<%=userId != null ? userId : ""%>">

                        <div class="mb-3">
                            <label class="form-label">Họ và tên người nhận</label>
                            <input type="text" name="recipientName" class="form-control" required
                                   value="<%=request.getParameter("recipientName") != null ? request.getParameter("recipientName") : ""%>">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" name="recipientPhone" class="form-control" required
                                   value="<%=request.getParameter("recipientPhone") != null ? request.getParameter("recipientPhone") : ""%>">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Địa chỉ giao hàng</label>
                            <textarea name="shippingAddress" class="form-control" rows="3" required><%=request.getParameter("shippingAddress") != null ? request.getParameter("shippingAddress") : ""%></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Mã voucher (nếu có)</label>
                            <input type="text" name="voucherCode" class="form-control" placeholder="Nhập mã giảm giá"
                                   value="<%=voucherCode != null ? voucherCode : ""%>">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Hình thức nhận hàng</label>
                            <select name="receiveMethod" class="form-select">
                                <option value="delivery" <%= "delivery".equals(request.getParameter("receiveMethod")) || request.getParameter("receiveMethod") == null ? "selected" : "" %>>Giao tận nơi</option>
                                <option value="pickup" <%= "pickup".equals(request.getParameter("receiveMethod")) ? "selected" : "" %>>Nhận tại cửa hàng</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Phương thức thanh toán</label>
                            <select name="paymentMethod" class="form-select">
                                <option value="COD" <%= "COD".equals(request.getParameter("paymentMethod")) || request.getParameter("paymentMethod") == null ? "selected" : "" %>>COD (Thanh toán khi nhận hàng)</option>
                                <option value="BANK_TRANSFER" <%= "BANK_TRANSFER".equals(request.getParameter("paymentMethod")) ? "selected" : "" %>>Chuyển khoản</option>
                                <option value="MOMO" <%= "MOMO".equals(request.getParameter("paymentMethod")) ? "selected" : "" %>>Ví MoMo (mô phỏng)</option>
                                <option value="VNPAY" <%= "VNPAY".equals(request.getParameter("paymentMethod")) ? "selected" : "" %>>VNPay (mô phỏng)</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ghi chú</label>
                            <textarea name="note" class="form-control" rows="2"><%=request.getParameter("note") != null ? request.getParameter("note") : ""%></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">Đặt hàng</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="card-title mb-3">Tóm tắt đơn hàng</h5>
                    <ul class="list-group list-group-flush">
                        <%
                            for (CartItem item : cart.values()) {
                                BigDecimal price = item.getProduct().getSalePrice() != null
                                        ? item.getProduct().getSalePrice()
                                        : item.getProduct().getPrice();
                                if (price == null) {
                                    price = BigDecimal.ZERO;
                                }
                                BigDecimal lineTotal = price.multiply(BigDecimal.valueOf(item.getQuantity()));
                        %>
                        <li class="list-group-item d-flex justify-content-between">
                            <div>
                                <div><strong><%=item.getProduct().getProductName()%></strong></div>
                                <small>x <%=item.getQuantity()%></small>
                            </div>
                            <span><%=String.format("%,.0f", lineTotal)%> VNĐ</span>
                        </li>
                        <% } %>
                    </ul>
                    <hr>
                    <div class="d-flex justify-content-between fw-bold">
                        <span>Tổng tạm tính</span>
                        <span><%=String.format("%,.0f", grandTotal)%> VNĐ</span>
                    </div>
                    <small class="text-muted d-block mt-2">Giảm giá voucher sẽ được áp dụng sau khi kiểm tra điều kiện.</small>
                </div>
            </div>
            <a href="<%=request.getContextPath()%>/cart" class="btn btn-outline-secondary mt-3 w-100">Quay lại giỏ hàng</a>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

