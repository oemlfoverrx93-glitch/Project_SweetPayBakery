<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Về chúng tôi - SweetPay Bakery</title>
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
            <span class="home-auth-chip"><%=HtmlUtil.escapeOr(navUserName, "Tài khoản")%></span>
            <a class="home-auth-link" href="<%=contextPath%>/logout">Đăng xuất</a>
            <% } else { %>
            <a class="home-auth-link primary" href="<%=contextPath%>/login">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</header>

<main class="container-xxl sweet-shell">
    <section class="home-story-section mt-0">
        <div class="home-story-copy">
            <span class="sweet-eyebrow">Về SweetPay Bakery</span>
            <h1 class="sweet-page-title">Một tiệm bánh nhỏ với tinh thần chỉn chu.</h1>
            <p>SweetPay Bakery được xây dựng như một không gian mua bánh trực tuyến gọn gàng, nơi khách hàng có thể xem sản phẩm, đặt hàng, thanh toán và theo dõi trạng thái đơn mà không phải nhắn tin qua nhiều kênh khác nhau.</p>
            <p>Về mặt cảm xúc thương hiệu, chúng tôi theo đuổi sự thanh lịch, nhiều khoảng trắng, hình ảnh bánh là trung tâm và một chút hồng pastel để giữ cảm giác ngọt ngào vừa đủ.</p>
            <a href="<%=contextPath%>/products" class="btn sweet-btn-primary">Khám phá thực đơn</a>
        </div>
        <div class="home-story-image">
            <img src="<%=contextPath%>/assets/images/products/biscotti.jpg" alt="SweetPay Bakery" loading="lazy"
                 onerror="this.onerror=null;this.src='<%=contextPath%>/assets/images/products/banh-kem-dau.jpg';">
        </div>
    </section>

    <section class="home-store-section">
        <div>
            <span class="sweet-eyebrow">Triết lý</span>
            <h2 class="home-section-title">Bánh ngon bắt đầu từ sự đơn giản.</h2>
        </div>
        <div class="home-store-grid">
            <div class="home-store-item">
                <strong>Ít nhiễu</strong>
                <span>Giao diện tập trung vào ảnh bánh, tên món, giá và thao tác mua hàng.</span>
            </div>
            <div class="home-store-item">
                <strong>Thủ công</strong>
                <span>Mỗi sản phẩm được trình bày như một món quà nhỏ, phù hợp sinh nhật, tiệc thân mật và ngày đặc biệt.</span>
            </div>
            <div class="home-store-item">
                <strong>Minh bạch</strong>
                <span>Khách hàng có thể theo dõi giỏ hàng, thanh toán và lịch sử đơn rõ ràng.</span>
            </div>
        </div>
    </section>

    <section class="team-section py-4">
        <span class="sweet-eyebrow d-flex justify-content-center">Đội ngũ</span>
        <h2 class="home-section-title text-center mb-5">Thành viên phát triển</h2>
        <div class="row g-4 justify-content-center">
            <div class="col-md-3 col-sm-6 text-center">
                <div class="member-card">
                    <div class="avatar-wrapper">
                        <img src="<%=contextPath%>/assets/images/mai.jpg" alt="Nguyễn Thị Tuyết Mai">
                    </div>
                    <h5 class="mt-3 mb-1">Nguyễn Thị Tuyết Mai</h5>
                    <p class="text-muted small">B24DCTC069</p>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 text-center">
                <div class="member-card">
                    <div class="avatar-wrapper">
                        <img src="<%=contextPath%>/assets/images/minh.jpg" alt="Trần Tuấn Minh">
                    </div>
                    <h5 class="mt-3 mb-1">Trần Tuấn Minh</h5>
                    <p class="text-muted small">B24DCTC073</p>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 text-center">
                <div class="member-card">
                    <div class="avatar-wrapper">
                        <img src="<%=contextPath%>/assets/images/nhung.jpg" alt="Nguyễn Hữu Thị Phương Nhung">
                    </div>
                    <h5 class="mt-3 mb-1">Nguyễn Hữu Thị Phương Nhung</h5>
                    <p class="text-muted small">B24DCTC079</p>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 text-center">
                <div class="member-card">
                    <div class="avatar-wrapper">
                        <img src="<%=contextPath%>/assets/images/linh.jpg" alt="Lưu Linh Linh">
                    </div>
                    <h5 class="mt-3 mb-1">Lưu Linh Linh</h5>
                    <p class="text-muted small">B24DCTC059</p>
                </div>
            </div>
        </div>
    </section>
</main>
</body>
</html>
