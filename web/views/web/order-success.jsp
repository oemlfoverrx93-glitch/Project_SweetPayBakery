<%@page import="com.sweetpay.model.Order"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng thành công - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <%
        Order order = (Order) request.getAttribute("order");
    %>

    <% if (order == null) { %>
    <div class="alert alert-warning">
        Không tìm thấy đơn hàng. <a href="<%=request.getContextPath()%>/order-history">Về lịch sử đơn</a>
    </div>
    <% } else { %>
    <div class="card shadow-sm border-0">
        <div class="card-body p-4 p-md-5 text-center">
            <h2 class="text-success fw-bold mb-3">Đặt hàng thành công</h2>
            <p class="mb-1">Mã đơn hàng của bạn:</p>
            <div class="fs-4 fw-bold mb-3"><%=order.getOrderCode()%></div>
            <p class="text-muted mb-4">
                Chúng tôi đã ghi nhận đơn hàng và sẽ xử lý sớm nhất.
            </p>

            <div class="d-flex flex-column flex-md-row justify-content-center gap-2">
                <a href="<%=request.getContextPath()%>/order-detail?id=<%=order.getOrderId()%>" class="btn btn-primary">
                    Xem chi tiết đơn hàng
                </a>
                <a href="<%=request.getContextPath()%>/order-history" class="btn btn-outline-secondary">
                    Xem lịch sử đơn hàng
                </a>
                <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-dark">
                    Tiếp tục mua sắm
                </a>
            </div>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

