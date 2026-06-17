<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-auth-page">
<%
    String error = request.getParameter("error");
    String redirect = (String) request.getAttribute("redirect");
    if (redirect == null) {
        redirect = request.getParameter("redirect");
    }
    if (redirect == null) {
        redirect = "";
    }
%>
<main class="container">
    <div class="sweet-auth-card">
        <div class="row g-0">
            <div class="col-lg-5 d-none d-lg-block">
                <div class="sweet-auth-panel">
                    <div>
                        <span class="sweet-eyebrow text-white">SweetPay Bakery</span>
                        <h1>Đơn bánh riêng cho từng khoảnh khắc.</h1>
                    </div>
                </div>
            </div>
            <div class="col-lg-7">
                <div class="p-4 p-md-5">
                    <a class="home-logo d-inline-block mb-4" href="<%=request.getContextPath()%>/home">SWEETPAY<span>BAKERY</span></a>
                    <h2 class="fw-bold mb-2">Đăng nhập</h2>
                    <p class="text-muted mb-4">Đăng nhập để thanh toán nhanh hơn và theo dõi trạng thái đơn hàng.</p>

                    <% if ("invalid".equals(error)) { %>
                    <div class="alert alert-danger">Email hoặc mật khẩu chưa đúng.</div>
                    <% } else if ("missing".equals(error)) { %>
                    <div class="alert alert-warning">Vui lòng nhập đầy đủ email và mật khẩu.</div>
                    <% } %>

                    <% if ("success".equals(request.getParameter("register"))) { %>
                    <div class="alert alert-success">Đăng ký thành công. Vui lòng đăng nhập bằng tài khoản vừa tạo.</div>
                    <% } %>

                    <form method="post" action="<%=request.getContextPath()%>/login" class="mb-4">
                        <input type="hidden" name="redirect" value="<%=HtmlUtil.escape(redirect)%>">
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required autocomplete="email">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" class="form-control" required autocomplete="current-password">
                        </div>
                        <button type="submit" class="btn btn-main w-100">Đăng nhập</button>
                    </form>

                    <div class="d-flex flex-column flex-md-row justify-content-between gap-2 mt-4">
                        <a href="<%=request.getContextPath()%>/register" class="text-decoration-none fw-semibold">Chưa có tài khoản? Đăng ký</a>
                        <a href="<%=request.getContextPath()%>/home" class="text-decoration-none">Quay về trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
</body>
</html>
