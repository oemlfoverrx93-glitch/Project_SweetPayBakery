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
    <style>
        body {
            font-family: 'Be Vietnam Pro', 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #fff6e9 0%, #ffe1d7 100%);
            min-height: 100vh;
        }

        .register-card {
            border: 0;
            border-radius: 20px;
            box-shadow: 0 18px 38px rgba(0, 0, 0, 0.12);
        }

        .btn-main {
            background: #5c3317;
            border: none;
            border-radius: 28px;
            color: #fff;
            font-weight: 600;
            padding: 10px 18px;
        }

        .btn-main:hover {
            background: #7a4522;
            color: #fff;
        }

        .form-control {
            border-radius: 10px;
            border: 1px solid #ddd;
        }

        .form-control:focus {
            border-color: #5c3317;
            box-shadow: 0 0 0 0.2rem rgba(92, 51, 23, 0.25);
        }

        .login-link {
            text-align: center;
            margin-top: 16px;
        }

        .login-link a {
            color: #5c3317;
            text-decoration: none;
            font-weight: 600;
        }

        .login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body class="d-flex align-items-center py-5">
<%
    String error = (String) request.getAttribute("error");
%>
<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-5 col-md-7">
            <div class="card register-card">
                <div class="card-body p-4 p-md-5">
                    <h3 class="fw-bold mb-1">Đăng ký tài khoản</h3>
                    <p class="text-muted mb-4">Tạo tài khoản để mua hàng và theo dõi đơn hàng của bạn.</p>

                    <% if (error != null && !error.isEmpty()) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= error %>
                    </div>
                    <% } %>

                    <form method="post" action="<%=request.getContextPath()%>/register" class="mb-4">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" placeholder="VD: Nguyễn Thị B" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" name="email" class="form-control" placeholder="VD: nguyenthib@gmail.com" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Số điện thoại</label>
                            <input type="text" name="phone" class="form-control" placeholder="VD: 0987654321" pattern="^[0-9]{10,11}$">
                            <small class="text-muted">Không bắt buộc. Nếu nhập phải từ 10-11 số.</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Mật khẩu</label>
                            <input type="password" name="password" class="form-control" placeholder="Nhập mật khẩu (ít nhất 6 ký tự)" required minlength="6">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Xác nhận mật khẩu</label>
                            <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required minlength="6">
                        </div>

                        <button type="submit" class="btn btn-main w-100">Đăng ký</button>
                    </form>

                    <div class="login-link">
                        Đã có tài khoản?
                        <a href="<%=request.getContextPath()%>/login">Đăng nhập ngay</a>
                    </div>

                    <div class="text-center mt-4">
                        <a href="<%=request.getContextPath()%>/home" class="small text-decoration-none">Quay về trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
