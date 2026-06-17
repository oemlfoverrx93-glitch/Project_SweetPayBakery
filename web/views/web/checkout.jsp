<%@page import="com.sweetpay.model.CartItem"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.util.Map"%>
<%@page import="com.sweetpay.util.CsrfUtil"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-checkout-page">
<%
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    String csrfToken = CsrfUtil.getToken(session);
    BigDecimal subtotal = (BigDecimal) request.getAttribute("subtotal");
    BigDecimal discountAmount = (BigDecimal) request.getAttribute("discountAmount");
    BigDecimal grandTotal = (BigDecimal) request.getAttribute("grandTotal");
    if (grandTotal == null) {
        grandTotal = BigDecimal.ZERO;
    }
    if (subtotal == null) {
        subtotal = grandTotal;
    }
    if (discountAmount == null) {
        discountAmount = BigDecimal.ZERO;
    }
    Object userIdObj = request.getAttribute("userId");
    Integer userId = (userIdObj instanceof Integer) ? (Integer) userIdObj : null;

    String error = (String) request.getAttribute("error");
    String voucherCode = (String) request.getAttribute("voucherCode");
    if (voucherCode == null) {
        voucherCode = request.getParameter("voucherCode");
    }
    String voucherSuccess = (String) request.getAttribute("voucherSuccess");
    String voucherError = (String) request.getAttribute("voucherError");
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=request.getContextPath()%>/home">SWEETPAY<span>BAKERY</span></a>
        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/products">Thực đơn</a>
            <a href="<%=request.getContextPath()%>/cart">Giỏ hàng</a>
        </nav>
        <div class="home-nav-icons">
            <a class="home-icon-button" href="<%=request.getContextPath()%>/cart" aria-label="Quay lại giỏ hàng">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><path d="M6 6h15l-1.5 8.5H8L6 3H3"></path><circle cx="9" cy="20" r="1.5"></circle><circle cx="18" cy="20" r="1.5"></circle></svg>
            </a>
        </div>
    </div>
</header>

<main class="container-xxl sweet-shell">
    <div class="sweet-page-heading">
        <div>
            <span class="sweet-eyebrow">Thanh toán</span>
            <h1 class="sweet-page-title">Hoàn tất đơn bánh</h1>
            <p class="sweet-page-subtitle">Không có banner gây nhiễu ở bước này, chỉ còn thông tin nhận hàng và xác nhận đơn.</p>
        </div>
        <a href="<%=request.getContextPath()%>/cart" class="btn btn-outline-dark">Quay lại giỏ</a>
    </div>

    <div class="checkout-steps">
        <div class="checkout-step">1. Giỏ hàng</div>
        <div class="checkout-step is-active">2. Thông tin</div>
        <div class="checkout-step">3. Thanh toán</div>
        <div class="checkout-step">4. Hoàn tất</div>
    </div>

    <% if (error != null) { %>
    <div class="alert alert-danger"><%= HtmlUtil.escape(error) %></div>
    <% } %>

    <% if (cart == null || cart.isEmpty()) { %>
    <div class="alert alert-warning">
        Giỏ hàng đang trống. <a href="<%=request.getContextPath()%>/products">Quay về thực đơn</a>
    </div>
    <% } else { %>

    <form id="checkoutForm" action="<%=request.getContextPath()%>/place-order" method="post">
        <input type="hidden" name="csrfToken" value="<%=csrfToken%>">
        <input type="hidden" name="userId" value="<%=userId != null ? userId : ""%>">
        <div class="row g-4">
            <div class="col-lg-7">
                <div class="card">
                    <div class="card-body p-4">
                        <h5 class="card-title mb-3">Thông tin nhận hàng</h5>

                        <div class="mb-3">
                            <label class="form-label">Họ và tên người nhận</label>
                            <input type="text" name="recipientName" class="form-control" required
                                   value="<%=HtmlUtil.escape(request.getParameter("recipientName"))%>">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" name="recipientPhone" class="form-control" required
                                   value="<%=HtmlUtil.escape(request.getParameter("recipientPhone"))%>">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Địa chỉ giao hàng</label>
                            <textarea name="shippingAddress" class="form-control" rows="3" required><%=HtmlUtil.escape(request.getParameter("shippingAddress"))%></textarea>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Hình thức nhận hàng</label>
                                <select name="receiveMethod" class="form-select">
                                    <option value="delivery" <%= "delivery".equals(request.getParameter("receiveMethod")) || request.getParameter("receiveMethod") == null ? "selected" : "" %>>Giao tận nơi</option>
                                    <option value="pickup" <%= "pickup".equals(request.getParameter("receiveMethod")) ? "selected" : "" %>>Nhận tại cửa hàng</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phương thức thanh toán</label>
                                <select name="paymentMethod" class="form-select">
                                    <option value="COD" <%= "COD".equals(request.getParameter("paymentMethod")) || request.getParameter("paymentMethod") == null ? "selected" : "" %>>COD</option>
                                    <option value="BANK_TRANSFER" <%= "BANK_TRANSFER".equals(request.getParameter("paymentMethod")) ? "selected" : "" %>>Chuyển khoản</option>
                                </select>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label">Ghi chú cho tiệm bánh</label>
                            <textarea name="note" class="form-control" rows="2" placeholder="VD: ít ngọt, ghi lời chúc, thời gian nhận..."><%=HtmlUtil.escape(request.getParameter("note"))%></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card order-summary">
                    <div class="card-body p-4">
                        <h5 class="card-title mb-3">Tóm tắt đơn hàng</h5>
                        <ul class="list-group list-group-flush mb-3">
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
                            <li class="list-group-item px-0 d-flex justify-content-between gap-3">
                                <div>
                                    <div><strong><%=HtmlUtil.escape(item.getProduct().getProductName())%></strong></div>
                                    <small class="text-muted">x <%=item.getQuantity()%></small>
                                </div>
                                <span><%=String.format("%,.0f", lineTotal)%> VNĐ</span>
                            </li>
                            <% } %>
                        </ul>

                        <label class="form-label">Mã voucher</label>
                        <div class="input-group mb-2">
                            <input type="text" name="voucherCode" class="form-control" placeholder="Nhập mã giảm giá"
                                   value="<%=HtmlUtil.escape(voucherCode)%>">
                            <button type="submit"
                                    class="btn btn-outline-dark"
                                    formaction="<%=request.getContextPath()%>/checkout"
                                    formmethod="get"
                                    formnovalidate>
                                Áp dụng
                            </button>
                        </div>
                        <% if (voucherSuccess != null) { %>
                        <div class="alert alert-success py-2"><%=HtmlUtil.escape(voucherSuccess)%></div>
                        <% } else if (voucherError != null) { %>
                        <div class="alert alert-warning py-2"><%=HtmlUtil.escape(voucherError)%></div>
                        <% } %>

                        <hr>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tạm tính</span>
                            <span><%=String.format("%,.0f", subtotal)%> VNĐ</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2 text-success">
                            <span>Giảm giá</span>
                            <span>-<%=String.format("%,.0f", discountAmount)%> VNĐ</span>
                        </div>
                        <div class="d-flex justify-content-between mb-3">
                            <span>Phí giao hàng</span>
                            <span>0 VNĐ</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-end fw-bold">
                            <span>Tổng thanh toán</span>
                            <span class="fs-4"><%=String.format("%,.0f", grandTotal)%> VNĐ</span>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 mt-4">Đặt hàng</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <% } %>
</main>
</body>
</html>
