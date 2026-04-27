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
    <title>Giới thiệu - SweetPay Bakery</title>
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

    String aboutImage = "assets/images/products/biscotti.jpg";
    for (Product p : navProducts) {
        if (p == null || p.getMainImage() == null || p.getMainImage().trim().isEmpty()) {
            continue;
        }

        if ("biscotti".equalsIgnoreCase(p.getSlug())) {
            aboutImage = p.getMainImage();
            break;
        }

        if ("assets/images/products/biscotti.jpg".equalsIgnoreCase(p.getMainImage())) {
            aboutImage = p.getMainImage();
            break;
        }

        if ("assets/images/products/biscotti.jpg".equals(aboutImage)) {
            aboutImage = p.getMainImage();
        }
    }
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

<main>
    <div class="about-breadcrumb">
        <div class="container-xxl">
            <a href="<%=contextPath%>/home">Trang chủ</a>
            <span>/</span>
            <strong>Giới thiệu</strong>
        </div>
    </div>

    <section class="about-container container-xxl">
        <div class="about-content">
            <h1 class="mb-4">Giới thiệu hệ thống</h1>
            
            <div class="about-section mb-4">
                <h3>1.1. Bối cảnh và Sự ra đời</h3>
                <p>
                    Hiện nay, nhiều cửa hàng bánh kẹo và bánh kem nhỏ lẻ vẫn chủ yếu bán hàng qua các kênh mạng xã hội như Facebook, Zalo hoặc qua điện thoại. Mặc dù cách thức vận hành này khá đơn giản và dễ thực hiện, nhưng lại tồn tại khá nhiều hạn chế lớn như dễ sót đơn hàng, khó kiểm soát tồn kho, khó quản lý các đơn bánh đặt theo yêu cầu cá nhân hóa, khó áp dụng voucher và chương trình khuyến mãi, khó theo dõi thanh toán, khó thống kê doanh thu cũng như xác định sản phẩm bán chạy, đồng thời khách hàng cũng không thể theo dõi được trạng thái đơn hàng của mình một cách thuận tiện.
                </p>
                <p>
                    Vì vậy, hệ thống <strong>SweetPay Bakery</strong> đã được xây dựng nhằm số hóa toàn bộ quy trình bán hàng trực tuyến dành cho các cửa hàng bánh ngọt. Hệ thống hỗ trợ từ việc trưng bày sản phẩm, tiếp nhận đơn hàng, xử lý thanh toán (mô phỏng), quản lý bánh đặt riêng theo yêu cầu, cho đến báo cáo doanh thu và quản trị tổng thể, giúp khắc phục triệt để những hạn chế của phương thức bán hàng truyền thống hiện nay.
                </p>
            </div>

            <div class="about-section mb-4">
                <h3>1.2. Mục tiêu hệ thống</h3>
                <p>
                    Hệ thống SweetPay Bakery được phát triển với các mục tiêu chính sau: hỗ trợ khách hàng mua bánh ngọt trực tuyến một cách nhanh chóng, tiện lợi; cho phép đặt bánh kem theo yêu cầu với mức độ cá nhân hóa cao; quản lý toàn diện các khâu sản phẩm, danh mục, đơn hàng, tồn kho và giao dịch thanh toán; hỗ trợ xây dựng và áp dụng voucher, chương trình khuyến mãi cùng cơ chế tích điểm; cho phép khách hàng theo dõi trạng thái đơn hàng thời gian thực; hỗ trợ báo cáo doanh thu chi tiết và thống kê sản phẩm bán chạy; đồng thời thể hiện rõ kiến thức chuyên sâu về lập trình Java Web, JDBC, mô hình MVC, các thao tác CRUD, quản lý session, filter, phân quyền người dùng cùng xử lý nghiệp vụ bán hàng thực tế.
                </p>
            </div>

            <div class="about-section mb-5">
                <h3>1.3. Lợi ích mang lại</h3>
                <p><strong>Đối với khách hàng:</strong> Hệ thống mang lại trải nghiệm mua sắm trực quan và chuyên nghiệp. Khách hàng có thể xem sản phẩm một cách rõ ràng, sinh động, dễ dàng tìm kiếm và lọc sản phẩm theo nhu cầu. Đặc biệt, khách hàng có thể đặt bánh kem theo sở thích cá nhân hóa, áp dụng voucher khi thanh toán, đồng thời theo dõi lịch sử mua hàng và trạng thái đơn hàng một cách thuận tiện mọi lúc mọi nơi.</p>
                <p><strong>Đối với cửa hàng:</strong> SweetPay Bakery giúp quản lý tập trung toàn bộ sản phẩm và đơn hàng trên một nền tảng duy nhất. Hệ thống giảm đáng kể sai sót trong khâu tiếp nhận đơn, kiểm soát chặt chẽ tồn kho và hạn sử dụng sản phẩm, triển khai chương trình khuyến mãi một cách dễ dàng và linh hoạt. Bên cạnh đó, cửa hàng có thể thống kê doanh thu chính xác, đánh giá hiệu quả kinh doanh và đưa ra các quyết định kinh doanh dựa trên dữ liệu thực tế.</p>
                <p><strong>Đối với quản trị viên:</strong> Hệ thống cung cấp giao diện quản lý trực quan, cho phép thực hiện các thao tác CRUD dữ liệu trực tiếp trên hệ thống. Nhân viên có thể cập nhật trạng thái đơn hàng và thanh toán nhanh chóng, quản lý sản phẩm, voucher, khách hàng một cách tập trung, đồng thời theo dõi báo cáo doanh thu và tình hình bán hàng một cách kịp thời.</p>
            </div>
        </div>

        <div class="about-image mb-5">
            <img src="<%=contextPath%>/<%=aboutImage%>" class="img-fluid rounded shadow-sm" alt="SweetPay Bakery Team">
        </div>
        <div class="team-section py-5">
            <h2 class="text-center mb-5" style="font-weight: 800; color: #333;">Thành viên cốt cán</h2>
            <div class="row g-4 justify-content-center">
                <div class="col-md-3 col-sm-6 text-center">
                    <div class="member-card">
                        <div class="avatar-wrapper">
                            <img src="<%=contextPath%>/assets/images/minh.jpg" alt="Trần T Minh">
                        </div>
                        <h5 class="mt-3 mb-1">Trần t Minh</h5>
                        <p class="text-muted small">MSV: B24DCTC000</p>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 text-center">
                    <div class="member-card">
                        <div class="avatar-wrapper">
                            <img src="<%=contextPath%>/assets/images/mai.jpg" alt="Nguyễn Thị T Mai">
                        </div>
                        <h5 class="mt-3 mb-1">Nguyễn Thị T Mai</h5>
                        <p class="text-muted small">MSV: B24DCTC000</p>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 text-center">
                    <div class="member-card">
                        <div class="avatar-wrapper">
                            <img src="<%=contextPath%>/assets/images/linh.jpg" alt="Lưu l Linh">
                        </div>
                        <h5 class="mt-3 mb-1">Lưu l Linh</h5>
                        <p class="text-muted small">MSV: B24DCTC000</p>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 text-center">
                    <div class="member-card">
                        <div class="avatar-wrapper">
                            <img src="<%=contextPath%>/assets/images/nhung.jpg" alt="Nguyễn Hữu T Phương Nhung">
                        </div>
                        <h5 class="mt-3 mb-1">Nguyễn Hữu T Phương Nhung</h5>
                        <p class="text-muted small">MSV: B24DCTC000</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>
</body>
</html>
