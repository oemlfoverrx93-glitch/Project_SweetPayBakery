<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="com.sweetpay.model.Product"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết sản phẩm - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="home-page">
<%
    String contextPath = request.getContextPath();
    Integer navUserId = session.getAttribute("userId") instanceof Integer ? (Integer) session.getAttribute("userId") : null;
    String navUserName = session.getAttribute("userFullName") != null ? String.valueOf(session.getAttribute("userFullName")) : "";
    boolean navIsAdmin = false;
    if (session.getAttribute("isAdmin") instanceof Boolean) {
        navIsAdmin = (Boolean) session.getAttribute("isAdmin");
    } else if (session.getAttribute("roleName") != null) {
        navIsAdmin = "admin".equalsIgnoreCase(String.valueOf(session.getAttribute("roleName")));
    }
    Map cart = session.getAttribute("cart") instanceof Map ? (Map) session.getAttribute("cart") : null;
    int cartCount = cart != null ? cart.size() : 0;
    Product p = (Product) request.getAttribute("product");
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY<span>BAKERY</span></a>
        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=contextPath%>/home">Trang chủ</a>
            <a href="<%=contextPath%>/products">Thực đơn</a>
            <a href="<%=contextPath%>/about">Về chúng tôi</a>
            <% if (navUserId != null) { %><a href="<%=contextPath%>/order-history">Đơn hàng</a><% } %>
            <% if (navIsAdmin) { %><a href="<%=contextPath%>/admin/dashboard">Quản trị</a><% } %>
        </nav>
        <div class="home-nav-icons">
            <a class="home-icon-button" href="<%=contextPath%>/products" aria-label="Tìm kiếm sản phẩm">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-3.5-3.5"></path></svg>
            </a>
            <a class="home-icon-button" href="<%=contextPath%>/cart" aria-label="Giỏ hàng">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><path d="M6 6h15l-1.5 8.5H8L6 3H3"></path><circle cx="9" cy="20" r="1.5"></circle><circle cx="18" cy="20" r="1.5"></circle></svg>
                <span class="home-cart-count"><%=cartCount%></span>
            </a>
            <% if (navUserId != null) { %>
            <span class="home-auth-chip"><%=navUserName == null || navUserName.trim().isEmpty() ? "Tài khoản" : navUserName%></span>
            <a class="home-auth-link" href="<%=contextPath%>/logout">Đăng xuất</a>
            <% } else { %>
            <a class="home-auth-link primary" href="<%=contextPath%>/login">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</header>

<main class="container-xxl sweet-shell">
    <% if (p != null) {
           String image = (p.getMainImage() != null && !p.getMainImage().trim().isEmpty())
                   ? p.getMainImage()
                   : "assets/images/products/bo.jpg";
           boolean hasSale = p.getSalePrice() != null && p.getSalePrice().compareTo(java.math.BigDecimal.ZERO) > 0;
           Integer stockObj = p.getQuantityInStock();
           int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
           boolean outOfStock = stockObj != null && stockQuantity <= 0;
           boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;
    %>
    <div class="mb-4">
        <a href="<%=contextPath%>/products" class="text-decoration-none text-muted">Thực đơn</a>
        <span class="text-muted mx-2">/</span>
        <span><%=p.getProductName()%></span>
    </div>

    <div class="row g-5 align-items-start">
        <div class="col-lg-6">
            <div class="product-detail-image">
                <img src="<%=contextPath%>/<%=image%>" alt="<%=p.getProductName()%>" class="w-100 product-detail-main-image" loading="lazy"
                     onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
            </div>
        </div>

        <div class="col-lg-6">
            <span class="sweet-eyebrow">Chi tiết sản phẩm</span>
            <h1 class="sweet-page-title mb-3"><%=p.getProductName()%></h1>

            <div class="home-product-price mb-3">
                <% if (hasSale) { %>
                <span class="home-price-sale fs-3"><%=String.format("%,.0f", p.getSalePrice())%>đ</span>
                <span class="home-price-origin"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                <% } else { %>
                <span class="home-price-sale fs-3"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                <% } %>
            </div>

            <span class="home-stock-badge <%= outOfStock ? "home-stock-out" : (lowStock ? "home-stock-low" : "home-stock-in") %>">
                <%= outOfStock ? "Hết hàng" : (lowStock ? "Sắp hết" : "Còn hàng") %>
            </span>

            <p class="product-detail-description mt-4 mb-0 text-muted">
                <%=p.getDescription() != null ? p.getDescription() : "Món bánh được chuẩn bị thủ công mỗi ngày với độ ngọt cân bằng và phần trang trí chỉn chu."%>
            </p>

            <div class="detail-amenities">
                <div class="detail-amenity">
                    <strong>Hương vị</strong>
                    <%=p.getFlavor() != null ? p.getFlavor() : "Theo mẻ bánh trong ngày"%>
                </div>
                <div class="detail-amenity">
                    <strong>Kích thước</strong>
                    <%=p.getSize() != null ? p.getSize() : "Tiêu chuẩn"%>
                </div>
                <div class="detail-amenity">
                    <strong>Lưu ý dị ứng</strong>
                    Báo trước cho tiệm nếu bạn dị ứng sữa, trứng hoặc gluten.
                </div>
            </div>

            <div class="text-secondary mb-4">
                <div><strong>SKU:</strong> <%=p.getSku() != null ? p.getSku() : "-"%></div>
                <div><strong>Bảo quản:</strong> Ưu tiên dùng trong ngày, giữ lạnh nếu chưa thưởng thức ngay.</div>
            </div>

            <div class="d-flex flex-wrap gap-2">
                <a href="<%=contextPath%>/products" class="btn btn-outline-secondary">Quay lại thực đơn</a>
                <% if (outOfStock) { %>
                <button type="button" class="btn btn-buy-disabled" disabled>Hết hàng</button>
                <% } else { %>
                <form action="<%=contextPath%>/add-to-cart" method="get" class="d-flex flex-wrap gap-2">
                    <input type="hidden" name="id" value="<%=p.getProductId()%>">
                    <input type="number" name="quantity" value="1" min="1"
                           <% if (stockObj != null && stockQuantity > 0) { %>max="<%=stockQuantity%>"<% } %>
                           class="form-control product-detail-qty">
                    <button type="submit" class="btn btn-buy">Thêm vào giỏ</button>
                </form>
                <% } %>
            </div>
        </div>
    </div>
    <% } else { %>
    <div class="home-empty">Không tìm thấy thông tin sản phẩm.</div>
    <% } %>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    if (status === 'success') {
        Swal.fire({
            title: 'Đã thêm vào giỏ',
            text: 'Món bánh đã nằm trong giỏ hàng của bạn.',
            icon: 'success',
            confirmButtonColor: '#292321',
            confirmButtonText: 'OK'
        });
    } else if (status === 'out-of-stock') {
        Swal.fire({
            title: 'Sản phẩm đã hết hàng',
            text: 'Món này hiện tạm hết, bạn chọn món khác giúp mình nhé.',
            icon: 'warning',
            confirmButtonColor: '#d982a7',
            confirmButtonText: 'Đã hiểu'
        });
    } else if (status === 'stock-limit') {
        const max = urlParams.get('max');
        const message = max
                ? `Số lượng tối đa có thể thêm là ${max}.`
                : 'Số lượng bạn chọn đang vượt quá tồn kho.';
        Swal.fire({
            title: 'Vượt quá tồn kho',
            text: message,
            icon: 'info',
            confirmButtonColor: '#292321',
            confirmButtonText: 'OK'
        });
    }
</script>
</body>
</html>
