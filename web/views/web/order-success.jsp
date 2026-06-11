<%@page import="com.sweetpay.model.Order"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng thành công - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-order-page">
<main class="container sweet-shell">
    <%
        Order order = (Order) request.getAttribute("order");
    %>

    <% if (order == null) { %>
    <div class="alert alert-warning">
        Không tìm thấy đơn hàng. <a href="<%=request.getContextPath()%>/order-history">Về lịch sử đơn</a>
    </div>
    <% } else { %>
    <div class="checkout-steps">
        <div class="checkout-step">1. Giỏ hàng</div>
        <div class="checkout-step">2. Thông tin</div>
        <div class="checkout-step">3. Thanh toán</div>
        <div class="checkout-step is-active">4. Hoàn tất</div>
    </div>

    <div class="card border-0">
        <div class="card-body p-4 p-md-5 text-center">
            <span class="sweet-eyebrow justify-content-center">Hoàn tất</span>
            <h1 class="sweet-page-title mb-3">Đặt hàng thành công</h1>
            <p class="mb-1 text-muted">Mã đơn hàng của bạn</p>
            <div class="fs-3 fw-bold mb-3"><%=order.getOrderCode()%></div>
            <p class="text-muted mb-4">
                Chúng tôi đã ghi nhận đơn hàng và sẽ xử lý sớm nhất. Bạn có thể theo dõi trạng thái trong lịch sử đơn hàng.
            </p>

            <div class="d-flex flex-column flex-md-row justify-content-center gap-2">
                <a href="<%=request.getContextPath()%>/order-detail?id=<%=order.getOrderId()%>" class="btn sweet-btn-primary">
                    Xem chi tiết đơn
                </a>
                <a href="<%=request.getContextPath()%>/order-history" class="btn btn-outline-secondary">
                    Lịch sử đơn hàng
                </a>
                <a href="<%=request.getContextPath()%>/products" class="btn btn-outline-dark">
                    Tiếp tục mua sắm
                </a>
            </div>
        </div>
    </div>
    <% } %>
</main>
</body>
</html>
