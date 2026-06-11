<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    String googleClientId = (String) request.getAttribute("googleClientId");
    if (googleClientId == null) {
        googleClientId = "";
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
                    <% } else if ("google-invalid".equals(error)) { %>
                    <div class="alert alert-danger">Không xác thực được Google ID token.</div>
                    <% } else if ("google-missing".equals(error)) { %>
                    <div class="alert alert-warning">Thiếu token đăng nhập Google.</div>
                    <% } else if ("google-user".equals(error)) { %>
                    <div class="alert alert-danger">Không thể tạo hoặc liên kết tài khoản Google.</div>
                    <% } %>

                    <% if ("success".equals(request.getParameter("register"))) { %>
                    <div class="alert alert-success">Đăng ký thành công. Vui lòng đăng nhập bằng tài khoản vừa tạo.</div>
                    <% } %>

                    <form method="post" action="<%=request.getContextPath()%>/login" class="mb-4">
                        <input type="hidden" name="redirect" value="<%=redirect%>">
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

                    <div class="text-center text-muted small mb-3">hoặc</div>

                    <% if (googleClientId != null && !googleClientId.trim().isEmpty()) { %>
                    <div id="g_id_onload"
                         data-client_id="<%=googleClientId%>"
                         data-context="signin"
                         data-ux_mode="popup"
                         data-callback="handleGoogleCredential"
                         data-auto_prompt="false">
                    </div>
                    <div class="d-flex justify-content-center">
                        <div class="g_id_signin"
                             data-type="standard"
                             data-shape="pill"
                             data-theme="outline"
                             data-text="signin_with"
                             data-size="large"
                             data-logo_alignment="left">
                        </div>
                    </div>
                    <% } else { %>
                    <div class="alert alert-info mb-0">
                        Đăng nhập Google chưa bật. Cấu hình biến <code>SWEETPAY_GOOGLE_CLIENT_ID</code> để sử dụng.
                    </div>
                    <% } %>

                    <form id="googleLoginForm" method="post" action="<%=request.getContextPath()%>/google-login" class="d-none">
                        <input type="hidden" name="credential" id="googleCredential">
                        <input type="hidden" name="redirect" value="<%=redirect%>">
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

<script src="https://accounts.google.com/gsi/client" async defer></script>
<script>
    function handleGoogleCredential(response) {
        if (!response || !response.credential) {
            return;
        }
        document.getElementById('googleCredential').value = response.credential;
        document.getElementById('googleLoginForm').submit();
    }
</script>
</body>
</html>
