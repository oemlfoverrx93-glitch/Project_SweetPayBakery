<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Collections"%>
<%@page import="com.sweetpay.model.Product"%>
<%@page import="com.sweetpay.model.Category"%>
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
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260410-theme1" rel="stylesheet">
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

    List<Category> navCategories = (List<Category>) request.getAttribute("navCategories");
    if (navCategories == null) {
        navCategories = Collections.emptyList();
    }

    List<Product> navProducts = (List<Product>) request.getAttribute("navProducts");
    if (navProducts == null) {
        navProducts = Collections.emptyList();
    }

    Product p = (Product) request.getAttribute("product");
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY BAKERY</a>

        <nav class="home-nav-links">
            <a href="<%=contextPath%>/about">Giới thiệu</a>
            <div class="home-nav-item home-dropdown">
                <a href="<%=contextPath%>/products" class="home-dropbtn">Sản phẩm</a>
                <div class="home-mega-menu">
                    <% if (!navCategories.isEmpty()) {
                           int megaLimit = Math.min(navCategories.size(), 5);
                           for (int i = 0; i < megaLimit; i++) {
                               Category c = navCategories.get(i);
                               int shown = 0;
                    %>
                    <div class="home-mega-column">
                        <h4><%=c.getCategoryName()%></h4>
                        <hr>
                        <% for (Product mp : navProducts) {
                               if (mp.getCategoryId() == c.getCategoryId()) {
                                   shown++;
                        %>
                        <a href="<%=contextPath%>/product-detail?id=<%=mp.getProductId()%>"><%=mp.getProductName()%></a>
                        <%         if (shown >= 5) break;
                               }
                           }
                           if (shown == 0) { %>
                        <a href="<%=contextPath%>/products?categoryId=<%=c.getCategoryId()%>">Xem sản phẩm</a>
                        <% } %>
                    </div>
                    <%     }
                       } else { %>
                    <div class="home-mega-column">
                        <h4>Sản phẩm</h4>
                        <hr>
                        <a href="<%=contextPath%>/products">Xem tất cả sản phẩm</a>
                    </div>
                    <% } %>
                </div>
            </div>
            <a href="<%=contextPath%>/home#store-list">Danh sách cửa hàng</a>
            <a href="<%=contextPath%>/home#news">Tin tức</a>
            <% if (navUserId != null) { %>
            <a href="<%=contextPath%>/order-history">Lịch sử đơn</a>
            <% } %>
            <% if (navIsAdmin) { %>
            <a href="<%=contextPath%>/admin/dashboard">Quản trị</a>
            <% } %>
        </nav>

        <div class="home-nav-icons">
            <a class="home-icon-button" href="<%=contextPath%>/products" title="Tìm kiếm sản phẩm">&#128269;</a>
            <a class="home-icon-button" href="<%=contextPath%>/cart" title="Giỏ hàng">
                &#128722;
                <span class="home-cart-count"><%=cartCount%></span>
            </a>
            <% if (navUserId != null) { %>
            <span class="home-auth-chip"><%=navUserName == null || navUserName.trim().isEmpty() ? "Tài khoản" : navUserName%></span>
            <a class="home-auth-link" href="<%=contextPath%>/logout">Đăng xuất</a>
            <% } else { %>
            <a class="home-auth-link" href="<%=contextPath%>/login">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</header>

<main class="container-xxl py-4">
    <% if (p != null) {
           String image = (p.getMainImage() != null && !p.getMainImage().trim().isEmpty())
                   ? p.getMainImage()
                   : "assets/images/products/banh-kem-dau.jpg";
           boolean hasSale = p.getSalePrice() != null && p.getSalePrice().compareTo(java.math.BigDecimal.ZERO) > 0;
           Integer stockObj = p.getQuantityInStock();
           int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
           boolean outOfStock = stockObj != null && stockQuantity <= 0;
           boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;
    %>
    <div class="card border-0 shadow-sm p-3 p-md-4">
        <div class="row g-4 align-items-start">
            <div class="col-lg-6">
                <img src="<%=contextPath%>/<%=image%>" alt="<%=p.getProductName()%>" class="w-100 rounded-4" style="max-height: 500px; object-fit: cover;">
            </div>
            <div class="col-lg-6">
                <span class="badge text-bg-success mb-2">Chi tiết sản phẩm</span>
                <h1 class="h2 fw-bold mb-3"><%=p.getProductName()%></h1>

                <div class="home-product-price mb-3">
                    <% if (hasSale) { %>
                    <span class="home-price-sale fs-4"><%=String.format("%,.0f", p.getSalePrice())%>đ</span>
                    <span class="home-price-origin"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                    <% } else { %>
                    <span class="home-price-sale fs-4"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                    <% } %>
                </div>
                <span class="home-stock-badge <%= outOfStock ? "home-stock-out" : (lowStock ? "home-stock-low" : "home-stock-in") %>">
                    <%= outOfStock ? "Hết hàng" : (lowStock ? "Sắp hết" : "Còn hàng") %>
                </span>

                <div class="text-secondary mb-3">
                    <div><strong>SKU:</strong> <%=p.getSku() != null ? p.getSku() : "-"%></div>
                    <div><strong>Hương vị:</strong> <%=p.getFlavor() != null ? p.getFlavor() : "-"%></div>
                    <div><strong>Kích thước:</strong> <%=p.getSize() != null ? p.getSize() : "-"%></div>
                </div>

                <p class="mb-4"><%=p.getDescription() != null ? p.getDescription() : "Chưa có mô tả sản phẩm."%></p>

                <div class="d-flex flex-wrap gap-2">
                    <a href="<%=contextPath%>/products" class="btn btn-outline-secondary">Quay lại</a>
                    <% if (outOfStock) { %>
                    <button type="button" class="btn btn-buy-disabled" disabled>Hết hàng</button>
                    <% } else { %>
                    <a href="<%=contextPath%>/add-to-cart?id=<%=p.getProductId()%>" class="btn btn-buy">Thêm vào giỏ</a>
                    <% } %>
                </div>
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
            confirmButtonColor: '#8CC63F',
            confirmButtonText: 'OK'
        });
    } else if (status === 'out-of-stock') {
        Swal.fire({
            title: 'Sản phẩm đã hết hàng',
            text: 'Món này hiện tạm hết, bạn chọn món khác giúp mình nhé.',
            icon: 'warning',
            confirmButtonColor: '#d97706',
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
            confirmButtonColor: '#3b82f6',
            confirmButtonText: 'OK'
        });
    }
</script>
</body>
</html>
