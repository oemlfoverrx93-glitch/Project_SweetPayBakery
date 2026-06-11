<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-auth-page">
<%
    String error = (String) request.getAttribute("error");
%>
<main class="container">
    <div class="sweet-auth-card">
        <div class="row g-0">
            <div class="col-lg-5 d-none d-lg-block">
                <div class="sweet-auth-panel">
                    <div>
                        <span class="sweet-eyebrow text-white">Tài khoản thành viên</span>
                        <h1>Lưu lại hương vị yêu thích của bạn.</h1>
                    </div>
                </div>
            </div>
            <div class="col-lg-7">
                <div class="p-4 p-md-5">
                    <a class="home-logo d-inline-block mb-4" href="<%=request.getContextPath()%>/home">SWEETPAY<span>BAKERY</span></a>
                    <h2 class="fw-bold mb-2">Đăng ký tài khoản</h2>
                    <p class="text-muted mb-4">Tạo tài khoản để mua hàng, lưu thông tin nhận bánh và theo dõi đơn hàng.</p>

                    <% if (error != null && !error.isEmpty()) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= error %>
                    </div>
                    <% } %>

                    <form method="post" action="<%=request.getContextPath()%>/register" class="mb-4">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" placeholder="VD: Nguyễn Thị B" required autocomplete="name">
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" name="email" class="form-control" placeholder="VD: nguyenthib@gmail.com" required autocomplete="email">
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Số điện thoại</label>
                            <input type="text" name="phone" class="form-control" placeholder="VD: 0987654321" pattern="^[0-9]{10,11}$" autocomplete="tel">
                            <small class="text-muted">Không bắt buộc. Nếu nhập phải từ 10-11 số.</small>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" placeholder="Ít nhất 6 ký tự" required minlength="6" autocomplete="new-password">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Xác nhận mật khẩu</label>
                                <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required minlength="6" autocomplete="new-password">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-main w-100 mt-4">Đăng ký</button>
                    </form>

                    <div class="d-flex flex-column flex-md-row justify-content-between gap-2">
                        <a href="<%=request.getContextPath()%>/login" class="text-decoration-none fw-semibold">Đã có tài khoản? Đăng nhập</a>
                        <a href="<%=request.getContextPath()%>/home" class="text-decoration-none">Quay về trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
