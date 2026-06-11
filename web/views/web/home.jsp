<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, java.util.Collections, com.sweetpay.model.Product, com.sweetpay.model.Category"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SweetPay Bakery - Bánh ngọt thủ công</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="home-page">
<%
    String contextPath = request.getContextPath();
    Integer navUserId = (Integer) session.getAttribute("userId");
    String navUserName = (String) session.getAttribute("userFullName");

    boolean navIsAdmin = false;
    Object isAdminObj = session.getAttribute("isAdmin");
    if (isAdminObj instanceof Boolean && (Boolean)isAdminObj) {
        navIsAdmin = true;
    } else if (session.getAttribute("roleName") != null) {
        navIsAdmin = "admin".equalsIgnoreCase(String.valueOf(session.getAttribute("roleName")));
    }

    Map cart = (Map) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;

    List<Product> productList = (List<Product>) request.getAttribute("productList");
    if (productList == null) productList = Collections.emptyList();

    List<Category> categoryList = (List<Category>) request.getAttribute("categories");
    if (categoryList == null) categoryList = Collections.emptyList();
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY<span>BAKERY</span></a>

        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=contextPath%>/home">Trang chủ</a>
            <a href="<%=contextPath%>/products">Thực đơn</a>
            <a href="<%=contextPath%>/about">Về chúng tôi</a>
            <a href="#store-list">Cửa hàng</a>
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
                <div class="user-profile">
                    <span class="home-auth-chip">Chào, <%=navUserName%></span>
                    <a class="home-auth-link" href="<%=contextPath%>/logout">Đăng xuất</a>
                </div>
            <% } else { %>
                <a class="home-auth-link primary" href="<%=contextPath%>/login">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</header>

<main class="home-main container-xxl">
    <section class="home-hero">
        <div id="homeHeroCarousel" class="carousel slide home-carousel" data-bs-ride="carousel">
            <div class="carousel-inner">
                <% if (!productList.isEmpty()) {
                    for (int i = 0; i < Math.min(productList.size(), 3); i++) {
                        Product p = productList.get(i);
                        String heroImage = (p.getMainImage() != null && !p.getMainImage().trim().isEmpty())
                                ? p.getMainImage().trim().replace('\\', '/')
                                : "assets/images/products/tiramisu.jpg";
                %>
                <div class="carousel-item <%= i == 0 ? "active" : "" %>">
                    <img src="<%=contextPath%>/<%=heroImage%>" class="d-block w-100" alt="<%=p.getProductName()%>"
                         onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/tiramisu.jpg';">
                    <div class="carousel-caption home-hero-caption">
                        <span class="home-hero-label">Bộ sưu tập trong ngày</span>
                        <h2><%=p.getProductName()%></h2>
                        <p class="d-none d-md-block text-truncate-2"><%=p.getDescription() != null ? p.getDescription() : "Bánh thủ công với vị ngọt tinh tế và phần trang trí chỉn chu."%></p>
                        <a href="<%=contextPath%>/products" class="btn btn-light home-hero-cta">Khám phá thực đơn</a>
                    </div>
                </div>
                <% } } else { %>
                <div class="carousel-item active">
                    <img src="<%=contextPath%>/assets/images/products/tiramisu.jpg" class="d-block w-100" alt="SweetPay Bakery">
                    <div class="carousel-caption home-hero-caption">
                        <span class="home-hero-label">SweetPay Bakery</span>
                        <h2>Bánh ngọt thủ công cho từng khoảnh khắc.</h2>
                        <p class="d-none d-md-block">Một thực đơn nhỏ gọn, tinh tế, được chuẩn bị mỗi ngày với nguyên liệu chọn lọc.</p>
                        <a href="<%=contextPath%>/products" class="btn btn-light home-hero-cta">Khám phá thực đơn</a>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </section>

    <section class="home-category-wrap">
        <h2 class="home-section-title text-center mb-4">Danh mục đặc sắc</h2>
        <div class="home-category-bar">
            <% for (Category cat : categoryList) {
                String catName = cat.getCategoryName() != null ? cat.getCategoryName().trim() : "";
                String categoryImage = "assets/images/products/bo.jpg";
                if ("Bánh kem".equalsIgnoreCase(catName)) {
                    categoryImage = "assets/images/products/banhkemm.jpg";
                } else if ("Bánh ngọt".equalsIgnoreCase(catName)) {
                    categoryImage = "assets/images/products/banhngot.jpg";
                } else if ("Cookie".equalsIgnoreCase(catName)) {
                    categoryImage = "assets/images/products/cookies2.jpg";
                }
            %>
            <a class="home-category-item" href="<%=contextPath%>/products?categoryId=<%=cat.getCategoryId()%>">
                <div class="home-icon-circle">
                    <img src="<%=contextPath%>/<%=categoryImage%>" alt="<%=cat.getCategoryName()%>" loading="lazy"
                         onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
                </div>
                <span class="home-category-label"><%=cat.getCategoryName()%></span>
            </a>
            <% } %>
        </div>
    </section>

    <section class="home-featured-wrap">
        <div class="home-featured-header">
            <div>
                <span class="sweet-eyebrow">Gợi ý</span>
                <h2 class="home-section-title">Những món đang được yêu thích</h2>
            </div>
            <a href="<%=contextPath%>/products" class="home-featured-link">Xem tất cả</a>
        </div>

        <div class="home-product-grid">
            <% for (Product p : productList) {
                boolean hasSale = p.getSalePrice() != null && p.getSalePrice().doubleValue() > 0;
                Integer stockObj = p.getQuantityInStock();
                int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
                boolean outOfStock = stockObj != null && stockQuantity <= 0;
                boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;
                String cardImage = (p.getMainImage() != null && !p.getMainImage().trim().isEmpty())
                        ? p.getMainImage().trim().replace('\\', '/')
                        : "assets/images/products/bo.jpg";
            %>
            <article class="home-product-card">
                <a class="home-product-image-link position-relative" href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>">
                    <% if (hasSale) { %><span class="home-sale-badge">Sale</span><% } %>
                    <img src="<%=contextPath%>/<%=cardImage%>" alt="<%=p.getProductName()%>" loading="lazy"
                         onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
                </a>
                <div class="home-product-body">
                    <h3><a href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>"><%=p.getProductName()%></a></h3>
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
                        <% if (outOfStock) { %>
                        <button type="button" class="btn btn-buy-disabled w-100" disabled>Hết hàng</button>
                        <% } else { %>
                        <a href="<%=contextPath%>/add-to-cart?id=<%=p.getProductId()%>" class="btn btn-buy w-100">Thêm vào giỏ</a>
                        <% } %>
                    </div>
                </div>
            </article>
            <% } %>
        </div>
    </section>

    <section class="home-story-section">
        <div class="home-story-copy">
            <span class="sweet-eyebrow">Brand story</span>
            <h2 class="home-section-title">Tinh thần thủ công trong từng lớp bánh</h2>
            <p>SweetPay Bakery giữ thực đơn gọn, ưu tiên nguyên liệu rõ nguồn gốc và cách trình bày tinh tế. Mỗi chiếc bánh được xem như một món quà nhỏ: đủ sang trọng để xuất hiện trong dịp đặc biệt, nhưng vẫn đủ gần gũi cho một buổi chiều ngọt ngào.</p>
            <a href="<%=contextPath%>/about" class="btn btn-outline-dark">Về chúng tôi</a>
        </div>
        <div class="home-story-image">
            <img src="<%=contextPath%>/assets/images/products/banh-kem-dau.jpg" alt="Bánh kem thủ công" loading="lazy">
        </div>
    </section>

    <section id="store-list" class="home-store-section">
        <div>
            <span class="sweet-eyebrow">Cửa hàng</span>
            <h2 class="home-section-title">Ghé tiệm hoặc đặt bánh trực tuyến</h2>
        </div>
        <div class="home-store-grid">
            <div class="home-store-item">
                <strong>SweetPay Bakery Flagship</strong>
                <span>Quận 1, TP. Hồ Chí Minh</span>
                <span>08:00 - 21:30 mỗi ngày</span>
            </div>
            <div class="home-store-item">
                <strong>Hotline</strong>
                <span>0900 000 000</span>
                <span>Nhận tư vấn bánh sinh nhật, tiệc nhỏ và quà tặng.</span>
            </div>
            <div class="home-store-item">
                <strong>Đặt trước</strong>
                <span>Nên đặt trước 24 giờ với bánh kem trang trí riêng.</span>
                <span>Thanh toán COD hoặc chuyển khoản.</span>
            </div>
        </div>
    </section>
</main>

<footer class="home-footer">
    <div class="container-xxl home-footer-inner">
        <div>
            <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY<span>BAKERY</span></a>
            <p>Không gian bánh ngọt thủ công, thanh lịch và vừa đủ đáng yêu cho những dịp đáng nhớ.</p>
        </div>
        <form class="home-newsletter" action="<%=contextPath%>/home" method="get">
            <label for="newsletterEmail">Nhận thông báo về hương vị mới theo mùa</label>
            <div>
                <input id="newsletterEmail" type="email" class="form-control" placeholder="Email của bạn">
                <button type="submit" class="btn sweet-btn-primary">Đăng ký</button>
            </div>
        </form>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>
