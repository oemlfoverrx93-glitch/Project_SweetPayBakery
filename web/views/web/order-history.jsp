<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String viStatus(String status) {
        if (status == null) return "-";
        if ("pending".equals(status)) return "Chờ xác nhận";
        if ("confirmed".equals(status)) return "Đã xác nhận";
        if ("preparing".equals(status)) return "Đang chuẩn bị";
        if ("ready_for_delivery".equals(status)) return "Sẵn sàng giao";
        if ("delivery_failed".equals(status)) return "Giao chưa thành công";
        if ("VNPAY".equals(status)) return "VNPAY Sandbox";
        if ("shipping".equals(status)) return "Đang giao";
        if ("ready_for_pickup".equals(status)) return "Chờ nhận tại tiệm";
        if ("completed".equals(status)) return "Hoàn tất";
        if ("cancelled".equals(status)) return "Đã hủy";
        if ("unpaid".equals(status)) return "Chưa thanh toán";
        if ("paid".equals(status)) return "Đã thanh toán";
        if ("failed".equals(status)) return "Thất bại";
        if ("refunded".equals(status)) return "Đã hoàn tiền";
        return status;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử đơn hàng - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-order-page">
<main class="container-xxl sweet-shell">
    <div class="sweet-page-heading">
        <div>
            <span class="sweet-eyebrow">Đơn hàng</span>
            <h1 class="sweet-page-title">Lịch sử đơn hàng</h1>
            <p class="sweet-page-subtitle">Theo dõi lại các đơn bánh đã đặt và trạng thái xử lý hiện tại.</p>
        </div>
        <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-dark">Về trang chủ</a>
    </div>

    <% if ("forbidden".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">Bạn không có quyền xem đơn hàng đó.</div>
    <% } %>

    <%
        List<Order> orders = (List<Order>) request.getAttribute("orders");
    %>

    <% if (orders == null || orders.isEmpty()) { %>
    <div class="home-empty">
        <p class="h5 mb-2">Bạn chưa có đơn hàng nào</p>
        <a href="<%=request.getContextPath()%>/products" class="btn sweet-btn-primary mt-2">Khám phá thực đơn</a>
    </div>
    <% } else { %>
    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Ngày đặt</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái đơn</th>
                        <th>Thanh toán</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Order order : orders) { %>
                    <tr>
                        <td><strong><%=HtmlUtil.escape(order.getOrderCode())%></strong></td>
                        <td><%=order.getOrderDate()%></td>
                        <td><%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</td>
                        <td><span class="badge bg-secondary"><%=viStatus(order.getOrderStatus())%></span></td>
                        <td><span class="badge bg-dark"><%=viStatus(order.getPaymentStatus())%></span></td>
                        <td class="text-end">
                            <a class="btn btn-sm btn-primary"
                               href="<%=request.getContextPath()%>/order-detail?id=<%=order.getOrderId()%>">
                                Xem chi tiết
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <% } %>
</main>
</body>
</html>
