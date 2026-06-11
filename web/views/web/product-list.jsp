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
    <title>Thực đơn bánh - SweetPay Bakery</title>
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

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        products = Collections.emptyList();
    }

    List<Category> navCategories = (List<Category>) request.getAttribute("navCategories");
    if (navCategories == null) {
        navCategories = Collections.emptyList();
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
    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null) {
        selectedSort = "default";
    }
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY<span>BAKERY</span></a>
        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=contextPath%>/home">Trang chủ</a>
            <a href="<%=contextPath%>/products">Thực đơn</a>
            <a href="<%=contextPath%>/about">Về chúng tôi</a>
            <a href="<%=contextPath%>/home#store-list">Cửa hàng</a>
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
    <div class="sweet-page-heading">
        <div>
            <span class="sweet-eyebrow">Thực đơn</span>
            <h1 class="sweet-page-title">Bộ sưu tập bánh trong ngày</h1>
            <p class="sweet-page-subtitle">Hình ảnh được đặt làm trung tâm, bộ lọc giữ gọn để trải nghiệm giống một phòng trưng bày bánh.</p>
        </div>
        <a href="<%=contextPath%>/home" class="btn btn-outline-dark">Về trang chủ</a>
    </div>

    <div class="sweet-card p-3 p-md-4 mb-4">
        <form class="row g-3 align-items-end" method="get" action="<%=contextPath%>/products">
            <div class="col-lg-4">
                <label class="form-label">Tìm kiếm</label>
                <input type="text" class="form-control" name="q" placeholder="Tên bánh, hương vị, mô tả..."
                       value="<%=keyword%>">
            </div>
            <div class="col-lg-3">
                <label class="form-label">Danh mục</label>
                <select class="form-select" name="categoryId">
                    <option value="">Tất cả danh mục</option>
                    <% for (Category c : navCategories) {
                           boolean selected = selectedCategory != null && selectedCategory.intValue() == c.getCategoryId();
                    %>
                    <option value="<%=c.getCategoryId()%>" <%=selected ? "selected" : ""%>><%=c.getCategoryName()%></option>
                    <% } %>
                </select>
            </div>
            <div class="col-lg-3">
                <label class="form-label">Sắp xếp</label>
                <select class="form-select" name="sort">
                    <option value="default" <%= "default".equals(selectedSort) ? "selected" : "" %>>Mặc định</option>
                    <option value="price-asc" <%= "price-asc".equals(selectedSort) ? "selected" : "" %>>Giá thấp đến cao</option>
                    <option value="price-desc" <%= "price-desc".equals(selectedSort) ? "selected" : "" %>>Giá cao đến thấp</option>
                    <option value="sale" <%= "sale".equals(selectedSort) ? "selected" : "" %>>Đang ưu đãi</option>
                    <option value="name-asc" <%= "name-asc".equals(selectedSort) ? "selected" : "" %>>Tên A-Z</option>
                </select>
            </div>
            <div class="col-lg-2 d-flex gap-2">
                <button type="submit" class="btn sweet-btn-primary w-100">Lọc</button>
                <a href="<%=contextPath%>/products" class="btn btn-outline-secondary w-100">Xóa</a>
            </div>
        </form>
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
                       : "assets/images/products/bo.jpg";
               String description = p.getDescription() != null ? p.getDescription() : "";
               boolean hasSale = p.getSalePrice() != null && p.getSalePrice().compareTo(java.math.BigDecimal.ZERO) > 0;
               Integer stockObj = p.getQuantityInStock();
               int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
               boolean outOfStock = stockObj != null && stockQuantity <= 0;
               boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;
        %>
        <article class="home-product-card">
            <a class="home-product-image-link position-relative" href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>">
                <% if (hasSale) { %><span class="home-sale-badge">Sale</span><% } %>
                <img src="<%=contextPath%>/<%=image%>" alt="<%=p.getProductName()%>" loading="lazy"
                     onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
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
