<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Collections"%>
<%@page import="com.sweetpay.model.Product"%>
<%@page import="com.sweetpay.model.Category"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách sản phẩm - SweetPay Bakery</title>
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

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        products = Collections.emptyList();
    }

    List<Category> navCategories = (List<Category>) request.getAttribute("navCategories");
    if (navCategories == null) {
        navCategories = Collections.emptyList();
    }

    List<Product> navProducts = (List<Product>) request.getAttribute("navProducts");
    if (navProducts == null) {
        navProducts = products;
    }
    if (navProducts == null) {
        navProducts = Collections.emptyList();
    }

    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) {
        keyword = request.getParameter("q");
    }
    if (keyword == null) {
        keyword = "";
    }

    Integer selectedCategory = request.getAttribute("selectedCategory") instanceof Integer
            ? (Integer) request.getAttribute("selectedCategory")
            : null;
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
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-3">
        <h1 class="h3 mb-0">Danh sách sản phẩm</h1>
        <a href="<%=contextPath%>/home" class="btn btn-outline-secondary btn-sm">Về trang chủ</a>
    </div>

    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body">
            <form class="row g-2" method="get" action="<%=contextPath%>/products">
                <div class="col-md-5">
                    <input type="text" class="form-control" name="q" placeholder="Tìm theo tên bánh, hương vị, mô tả..."
                           value="<%=keyword%>">
                </div>
                <div class="col-md-4">
                    <select class="form-select" name="categoryId">
                        <option value="">Tất cả danh mục</option>
                        <% for (Category c : navCategories) {
                               boolean selected = selectedCategory != null && selectedCategory.intValue() == c.getCategoryId();
                        %>
                        <option value="<%=c.getCategoryId()%>" <%=selected ? "selected" : ""%>><%=c.getCategoryName()%></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary w-100">Lọc</button>
                    <a href="<%=contextPath%>/products" class="btn btn-outline-secondary w-100">Xóa</a>
                </div>
            </form>
        </div>
    </div>

    <% if ("not-found".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">Không tìm thấy sản phẩm cần xem.</div>
    <% } %>

    <% if (products.isEmpty()) { %>
    <div class="home-empty">Chưa có sản phẩm nào phù hợp.</div>
    <% } else { %>
    <div class="home-product-grid">
        <% for (Product p : products) {
               String image = (p.getMainImage() != null && !p.getMainImage().trim().isEmpty())
                       ? p.getMainImage()
                       : "assets/images/products/banh-kem-dau.jpg";
               String description = p.getDescription() != null ? p.getDescription() : "";
               boolean hasSale = p.getSalePrice() != null && p.getSalePrice().compareTo(java.math.BigDecimal.ZERO) > 0;
               Integer stockObj = p.getQuantityInStock();
               int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
               boolean outOfStock = stockObj != null && stockQuantity <= 0;
               boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;
        %>
        <article class="home-product-card">
            <a class="home-product-image-link" href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>">
                <img src="<%=contextPath%>/<%=image%>" alt="<%=p.getProductName()%>">
            </a>
            <div class="home-product-body">
                <h3><a href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>"><%=p.getProductName()%></a></h3>
                <p class="home-product-desc"><%=description%></p>
                <div class="home-product-price">
                    <% if (hasSale) { %>
                    <span class="home-price-sale"><%=String.format("%,.0f", p.getSalePrice())%>đ</span>
                    <span class="home-price-origin"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                    <% } else { %>
                    <span class="home-price-sale"><%=String.format("%,.0f", p.getPrice())%>đ</span>
                    <% } %>
                </div>
                <span class="home-stock-badge <%= outOfStock ? "home-stock-out" : (lowStock ? "home-stock-low" : "home-stock-in") %>">
                    <%= outOfStock ? "Hết hàng" : (lowStock ? "Sắp hết" : "Còn hàng") %>
                </span>
                <div class="home-product-actions">
                    <a href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>" class="btn btn-outline-dark btn-sm">Chi tiết</a>
                    <% if (outOfStock) { %>
                    <button type="button" class="btn btn-buy-disabled btn-sm" disabled>Hết hàng</button>
                    <% } else { %>
                    <a href="<%=contextPath%>/add-to-cart?id=<%=p.getProductId()%>" class="btn btn-buy btn-sm">Thêm giỏ</a>
                    <% } %>
                </div>
            </div>
        </article>
        <% } %>
    </div>
    <% } %>
</main>
</body>
</html>
