<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, java.util.Collections, com.sweetpay.model.Product, com.sweetpay.model.Category"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SweetPay Bakery - Thiên Đường Bánh Ngọt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260410-theme1" rel="stylesheet">
</head>
<body class="home-page">
<%
    String contextPath = request.getContextPath();
    Integer navUserId = (Integer) session.getAttribute("userId");
    String navUserName = (String) session.getAttribute("userFullName");
    
    // Kiểm tra quyền Admin
    boolean navIsAdmin = false;
    Object isAdminObj = session.getAttribute("isAdmin");
    if (isAdminObj instanceof Boolean && (Boolean)isAdminObj) navIsAdmin = true;
    else if (session.getAttribute("roleName") != null) 
        navIsAdmin = "admin".equalsIgnoreCase(String.valueOf(session.getAttribute("roleName")));

    Map cart = (Map) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;

    // Xử lý dữ liệu hiển thị
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    if (productList == null) productList = Collections.emptyList();

    List<Category> categoryList = (List<Category>) request.getAttribute("categories");
    if (categoryList == null) categoryList = Collections.emptyList();

    List<Category> navCategories = (List<Category>) request.getAttribute("navCategories");
    if (navCategories == null) navCategories = categoryList;

    List<Product> navProducts = (List<Product>) request.getAttribute("navProducts");
    if (navProducts == null) navProducts = productList;
%>

<header class="home-navbar">
    <div class="home-navbar-inner container-xxl">
        <a class="home-logo" href="<%=contextPath%>/home">SWEETPAY<span>BAKERY</span></a>

        <nav class="home-nav-links d-none d-lg-flex">
            <a href="<%=contextPath%>/home">Trang chủ</a>
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
                            if (mp.getCategoryId() == c.getCategoryId() && shown < 5) {
                                shown++;
                        %>
                        <a href="<%=contextPath%>/product-detail?id=<%=mp.getProductId()%>"><%=mp.getProductName()%></a>
                        <% } } %>
                        <a href="<%=contextPath%>/products?categoryId=<%=c.getCategoryId()%>" class="see-more">Xem thêm...</a>
                    </div>
                    <% } } %>
                </div>
            </div>
            <a href="<%=contextPath%>/about">Về chúng tôi</a>
            <a href="#store-list">Cửa hàng</a>
            <% if (navIsAdmin) { %><a href="<%=contextPath%>/admin/dashboard" style="color: var(--home-danger);">Quản trị</a><% } %>
        </nav>

        <div class="home-nav-icons">
            <a class="home-icon-button" href="<%=contextPath%>/products"><i class="search-icon">🔍</i></a>
            <a class="home-icon-button" href="<%=contextPath%>/cart">
                <i class="cart-icon">🛒</i>
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

                        String heroImage = p.getMainImage();
                        if (heroImage != null) {
                            heroImage = heroImage.trim().replace('\\', '/');
                        }

                        if (heroImage == null || heroImage.isEmpty()) {
                            heroImage = "assets/images/products/bo.jpg";
                        } else {
                            boolean isAbsoluteUrl = heroImage.startsWith("http://") || heroImage.startsWith("https://");
                            if (!isAbsoluteUrl) {
                                String contextPrefix = contextPath + "/";
                                if (contextPath != null && !contextPath.isEmpty() && heroImage.startsWith(contextPrefix)) {
                                    heroImage = heroImage.substring(contextPrefix.length());
                                }
                                while (heroImage.startsWith("/")) {
                                    heroImage = heroImage.substring(1);
                                }

                                String lowerHeroImage = heroImage.toLowerCase();
                                int assetsPos = lowerHeroImage.indexOf("assets/images/products/");
                                int imagesPos = lowerHeroImage.indexOf("images/products/");
                                int productsPos = lowerHeroImage.indexOf("products/");

                                if (assetsPos >= 0) {
                                    heroImage = heroImage.substring(assetsPos);
                                } else if (imagesPos >= 0) {
                                    heroImage = "assets/" + heroImage.substring(imagesPos);
                                } else if (productsPos >= 0) {
                                    heroImage = "assets/images/" + heroImage.substring(productsPos);
                                } else if (heroImage.startsWith("web/")) {
                                    heroImage = heroImage.substring(4);
                                }

                                if (!heroImage.startsWith("assets/")) {
                                    heroImage = "assets/images/products/" + heroImage;
                                }
                            }
                        }

                        String heroSrc = (heroImage.startsWith("http://") || heroImage.startsWith("https://"))
                                ? heroImage
                                : contextPath + "/" + heroImage;

                        if (!heroImage.startsWith("http://") && !heroImage.startsWith("https://")) {
                            String realImagePath = application.getRealPath("/" + heroImage);
                            if (realImagePath != null) {
                                java.io.File imageFile = new java.io.File(realImagePath);
                                if (!imageFile.exists()) {
                                    heroImage = "assets/images/products/bo.jpg";
                                    heroSrc = contextPath + "/" + heroImage;
                                }
                            }
                        }
                %>
                <div class="carousel-item <%= i == 0 ? "active" : "" %>">
                    <img src="<%=heroSrc%>" class="d-block w-100" alt="<%=p.getProductName()%>"
                         onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
                    <div class="carousel-caption home-hero-caption">
                        <span class="home-hero-label">Bán chạy nhất</span>
                        <h2><%=p.getProductName()%></h2>
                        <p class="d-none d-md-block text-truncate-2"><%=p.getDescription()%></p>
                        <a href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>" class="btn btn-light home-hero-cta">Mua ngay</a>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>
    </section>

   <section class="home-category-wrap">
    <h2 class="home-section-title text-center mb-4">Danh mục đặc sắc</h2>
    <div class="home-category-bar">
        <% for (Category cat : categoryList) { 
            String catName = cat.getCategoryName() != null ? cat.getCategoryName().trim() : "";
            String categoryImage = "";

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
                <% if (!categoryImage.isEmpty()) { %>
                    <img src="<%=contextPath%>/<%=categoryImage%>" alt="<%=cat.getCategoryName()%>"
                         onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/bo.jpg';">
                <% } else { %>
                    <span class="home-icon-fallback"><%=cat.getCategoryName().substring(0,1)%></span>
                <% } %>
            </div>
            <span class="home-category-label"><%=cat.getCategoryName()%></span>
        </a>
        <% } %>
    </div>
</section>

    <section class="home-featured-wrap">
        <div class="home-featured-header">
            <h2 class="home-section-title">Gợi ý cho bạn</h2>
            <a href="<%=contextPath%>/products" class="home-featured-link">Xem tất cả ➔</a>
        </div>

        <div class="home-product-grid">
            <% for (Product p : productList) { 
                boolean hasSale = p.getSalePrice() != null && p.getSalePrice().doubleValue() > 0;
                Integer stockObj = p.getQuantityInStock();
                int stockQuantity = stockObj != null ? stockObj.intValue() : Integer.MAX_VALUE;
                boolean outOfStock = stockObj != null && stockQuantity <= 0;
                boolean lowStock = stockObj != null && stockQuantity > 0 && stockQuantity <= 5;

                String cardImage = p.getMainImage();
                if (cardImage != null) {
                    cardImage = cardImage.trim().replace('\\', '/');
                }

                if (cardImage == null || cardImage.isEmpty()) {
                    cardImage = "assets/images/products/bo.jpg";
                } else {
                    boolean isAbsoluteUrl = cardImage.startsWith("http://") || cardImage.startsWith("https://");
                    if (!isAbsoluteUrl) {
                        String contextPrefix = contextPath + "/";
                        if (contextPath != null && !contextPath.isEmpty() && cardImage.startsWith(contextPrefix)) {
                            cardImage = cardImage.substring(contextPrefix.length());
                        }
                        while (cardImage.startsWith("/")) {
                            cardImage = cardImage.substring(1);
                        }

                        String lowerCardImage = cardImage.toLowerCase();
                        int assetsPos = lowerCardImage.indexOf("assets/images/products/");
                        int imagesPos = lowerCardImage.indexOf("images/products/");
                        int productsPos = lowerCardImage.indexOf("products/");

                        if (assetsPos >= 0) {
                            cardImage = cardImage.substring(assetsPos);
                        } else if (imagesPos >= 0) {
                            cardImage = "assets/" + cardImage.substring(imagesPos);
                        } else if (productsPos >= 0) {
                            cardImage = "assets/images/" + cardImage.substring(productsPos);
                        } else if (cardImage.startsWith("web/")) {
                            cardImage = cardImage.substring(4);
                        }

                        if (!cardImage.startsWith("assets/")) {
                            cardImage = "assets/images/products/" + cardImage;
                        }

                        String realImagePath = application.getRealPath("/" + cardImage);
                        if (realImagePath != null) {
                            java.io.File imageFile = new java.io.File(realImagePath);
                            if (!imageFile.exists()) {
                                cardImage = "assets/images/products/bo.jpg";
                            }
                        }
                    }
                }

                String cardSrc = (cardImage.startsWith("http://") || cardImage.startsWith("https://"))
                        ? cardImage
                        : contextPath + "/" + cardImage;
            %>
            <article class="home-product-card">
                <a class="home-product-image-link" href="<%=contextPath%>/product-detail?id=<%=p.getProductId()%>">
                    <img src="<%=cardSrc%>" alt="<%=p.getProductName()%>" loading="lazy"
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
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>
