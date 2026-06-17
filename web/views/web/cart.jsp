<%@page import="com.sweetpay.model.CartItem"%>
<%@page import="java.util.Map"%>
<%@page import="com.sweetpay.util.CsrfUtil"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giỏ hàng của bạn - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-cart-page">
<%
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    String csrfToken = CsrfUtil.getToken(session);
    int cartCount = cart != null ? cart.size() : 0;
    String cartStatus = request.getParameter("status");
    String cartMax = request.getParameter("max");
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=request.getContextPath()%>/home">SWEETPAY<span>BAKERY</span></a>
        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/products">Thực đơn</a>
            <a href="<%=request.getContextPath()%>/about">Về chúng tôi</a>
            <a href="<%=request.getContextPath()%>/order-history">Đơn hàng</a>
        </nav>
        <div class="home-nav-icons">
            <a class="home-icon-button" href="<%=request.getContextPath()%>/products" aria-label="Tìm kiếm sản phẩm">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-3.5-3.5"></path></svg>
            </a>
            <a class="home-icon-button" href="<%=request.getContextPath()%>/cart" aria-label="Giỏ hàng">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><path d="M6 6h15l-1.5 8.5H8L6 3H3"></path><circle cx="9" cy="20" r="1.5"></circle><circle cx="18" cy="20" r="1.5"></circle></svg>
                <span class="home-cart-count"><%=cartCount%></span>
            </a>
        </div>
    </div>
</header>

<main class="container-xxl sweet-shell">
    <div class="sweet-page-heading">
        <div>
            <span class="sweet-eyebrow">Giỏ hàng</span>
            <h1 class="sweet-page-title">Những món bánh đã chọn</h1>
            <p class="sweet-page-subtitle">Kiểm tra lại số lượng trước khi chuyển sang bước nhập thông tin nhận hàng.</p>
        </div>
        <a href="<%=request.getContextPath()%>/products" class="btn btn-outline-dark">Tiếp tục chọn bánh</a>
    </div>

    <div class="checkout-steps">
        <div class="checkout-step is-active">1. Giỏ hàng</div>
        <div class="checkout-step">2. Thông tin</div>
        <div class="checkout-step">3. Thanh toán</div>
        <div class="checkout-step">4. Hoàn tất</div>
    </div>

    <% if ("stock-limit".equals(cartStatus)) { %>
    <div class="alert alert-warning">Số lượng vượt tồn kho. Bạn chỉ có thể chọn tối đa <strong><%=HtmlUtil.escapeOr(cartMax, "gioi han hien tai")%></strong>.</div>
    <% } else if ("out-of-stock".equals(cartStatus)) { %>
    <div class="alert alert-danger">Có sản phẩm vừa hết hàng nên giỏ đã được cập nhật lại.</div>
    <% } %>

    <div class="table-responsive bg-white p-4">
        <table class="table align-middle">
            <thead>
            <tr>
                <th>Sản phẩm</th>
                <th>Đơn giá</th>
                <th class="cart-qty-col">Số lượng</th>
                <th>Tổng tiền</th>
                <th class="text-center">Hành động</th>
            </tr>
            </thead>
            <tbody>
            <%
                double grandTotal = 0;
                if (cart != null && !cart.isEmpty()) {
                    for (CartItem item : cart.values()) {
                        double price = (item.getProduct().getSalePrice() != null)
                                ? item.getProduct().getSalePrice().doubleValue()
                                : item.getProduct().getPrice().doubleValue();
                        double subTotal = item.getQuantity() * price;
                        grandTotal += subTotal;
                        Integer availableStock = item.getProduct().getQuantityInStock();
                        String imagePath = (item.getProduct().getMainImage() != null)
                                ? item.getProduct().getMainImage()
                                : "assets/images/products/bo.jpg";
            %>
            <tr>
                <td>
                    <div class="d-flex align-items-center">
                        <img src="<%=request.getContextPath()%>/<%=HtmlUtil.escape(imagePath)%>" class="product-img-cart me-3 border" alt="<%=HtmlUtil.escape(item.getProduct().getProductName())%>" loading="lazy">
                        <div>
                            <h6 class="mb-1 fw-bold"><%=HtmlUtil.escape(item.getProduct().getProductName())%></h6>
                            <small class="text-muted">Vị: <%=HtmlUtil.escapeOr(item.getProduct().getFlavor(), "-")%></small>
                        </div>
                    </div>
                </td>
                <td><%= String.format("%,.0f", price) %> VNĐ</td>
                <td>
                    <form action="<%=request.getContextPath()%>/update-cart-quantity" method="post" class="quantity-form">
                        <input type="hidden" name="csrfToken" value="<%=csrfToken%>">
                        <input type="hidden" name="id" value="<%=item.getProduct().getProductId()%>">
                        <button type="submit" name="action" value="decrease" class="qty-btn" aria-label="Giảm số lượng">-</button>
                        <input type="number"
                               name="quantity"
                               value="<%=item.getQuantity()%>"
                               min="1"
                               <% if (availableStock != null && availableStock > 0) { %>max="<%=availableStock%>"<% } %>
                               class="qty-input"
                               onchange="this.form.submit()">
                        <button type="submit" name="action" value="increase" class="qty-btn" aria-label="Tăng số lượng">+</button>
                    </form>
                </td>
                <td class="fw-bold"><%= String.format("%,.0f", subTotal) %> VNĐ</td>
                <td class="text-center">
                    <form action="<%=request.getContextPath()%>/remove-from-cart" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa món này?')">
                        <input type="hidden" name="csrfToken" value="<%=csrfToken%>">
                        <input type="hidden" name="id" value="<%=item.getProduct().getProductId()%>">
                        <button type="submit" class="btn btn-sm btn-outline-danger">Xóa</button>
                    </form>
                </td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="5" class="text-center py-5">
                    <p class="h5 mb-2">Giỏ hàng đang trống</p>
                    <p class="text-muted mb-3">Chọn vài món bánh yêu thích để bắt đầu đơn hàng.</p>
                    <a href="<%=request.getContextPath()%>/products" class="btn sweet-btn-primary">Khám phá thực đơn</a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <% if (cart != null && !cart.isEmpty()) { %>
        <div class="row mt-4 align-items-center">
            <div class="col-md-6">
                <a href="<%=request.getContextPath()%>/products" class="btn btn-outline-secondary">Tiếp tục chọn bánh</a>
            </div>
            <div class="col-md-6 text-md-end mt-3 mt-md-0">
                <div class="mb-3 text-muted">Tổng thanh toán</div>
                <h3 class="mb-3"><%= String.format("%,.0f", grandTotal) %> VNĐ</h3>
                <a href="<%=request.getContextPath()%>/checkout" class="btn btn-checkout btn-lg">Thanh toán ngay</a>
            </div>
        </div>
        <% } %>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
