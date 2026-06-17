<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.OrderDetail"%>
<%@page import="com.sweetpay.model.Payment"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String viStatus(String status) {
        if (status == null) return "-";
        if ("pending".equals(status)) return "Chờ xác nhận";
        if ("confirmed".equals(status)) return "Đã xác nhận";
        if ("preparing".equals(status)) return "Đang chuẩn bị";
        if ("shipping".equals(status)) return "Đang giao";
        if ("ready_for_pickup".equals(status)) return "Chờ nhận tại tiệm";
        if ("completed".equals(status)) return "Hoàn tất";
        if ("cancelled".equals(status)) return "Đã hủy";
        if ("unpaid".equals(status)) return "Chưa thanh toán";
        if ("paid".equals(status)) return "Đã thanh toán";
        if ("failed".equals(status)) return "Thất bại";
        if ("refunded".equals(status)) return "Đã hoàn tiền";
        if ("delivery".equals(status)) return "Giao tận nơi";
        if ("pickup".equals(status)) return "Nhận tại cửa hàng";
        if ("COD".equals(status)) return "COD";
        if ("BANK_TRANSFER".equals(status)) return "Chuyển khoản";
        return status;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đơn hàng - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-order-page">
<main class="container-xxl sweet-shell">
    <%
        Order order = (Order) request.getAttribute("order");
        Payment payment = (Payment) request.getAttribute("payment");
    %>

    <% if (order == null) { %>
    <div class="alert alert-warning">
        Không tìm thấy đơn hàng. <a href="<%=request.getContextPath()%>/order-history">Về lịch sử đơn</a>
    </div>
    <% } else { %>
    <div class="sweet-page-heading">
        <div>
            <span class="sweet-eyebrow">Chi tiết đơn</span>
            <h1 class="sweet-page-title"><%=HtmlUtil.escape(order.getOrderCode())%></h1>
            <p class="sweet-page-subtitle">Thông tin nhận hàng, thanh toán và các sản phẩm trong đơn.</p>
        </div>
        <a href="<%=request.getContextPath()%>/order-history" class="btn btn-outline-dark">Về lịch sử đơn</a>
    </div>

    <% if ("1".equals(request.getParameter("success"))) { %>
    <div class="alert alert-success">Đơn hàng đã được ghi nhận thành công.</div>
    <% } %>

    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-body p-4">
                    <h5 class="card-title">Thông tin nhận hàng</h5>
                    <p><strong>Người nhận:</strong> <%=HtmlUtil.escape(order.getRecipientName())%></p>
                    <p><strong>Số điện thoại:</strong> <%=HtmlUtil.escape(order.getRecipientPhone())%></p>
                    <p><strong>Địa chỉ:</strong> <%=HtmlUtil.escape(order.getShippingAddress())%></p>
                    <p><strong>Hình thức nhận:</strong> <%=viStatus(order.getReceiveMethod())%></p>
                    <p><strong>Trạng thái đơn:</strong> <span class="badge bg-secondary"><%=viStatus(order.getOrderStatus())%></span></p>
                    <p><strong>Trạng thái thanh toán:</strong> <span class="badge bg-dark"><%=viStatus(order.getPaymentStatus())%></span></p>
                    <p><strong>Ngày đặt:</strong> <%=order.getOrderDate()%></p>
                    <p><strong>Ghi chú:</strong> <%=HtmlUtil.escapeOr(order.getNote(), "-")%></p>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-body p-4">
                    <h5 class="card-title">Thông tin thanh toán</h5>
                    <% if (payment != null) { %>
                    <p><strong>Phương thức:</strong> <%=viStatus(payment.getPaymentMethod())%></p>
                    <p><strong>Trạng thái:</strong> <%=viStatus(payment.getPaymentStatus())%></p>
                    <p><strong>Số tiền:</strong> <%=String.format("%,.0f", payment.getAmount())%> VNĐ</p>
                    <p><strong>Mã giao dịch:</strong> <%=HtmlUtil.escapeOr(payment.getTransactionCode(), "-")%></p>
                    <p><strong>Thời gian thanh toán:</strong> <%=payment.getPaidAt() != null ? payment.getPaidAt() : "-"%></p>
                    <% } else { %>
                    <p class="text-muted mb-0">Chưa có bản ghi thanh toán.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div class="card mt-4">
        <div class="card-body p-4">
            <h5 class="card-title">Sản phẩm trong đơn</h5>
            <div class="table-responsive">
                <table class="table">
                    <thead>
                    <tr>
                        <th>Mã sản phẩm</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Thành tiền</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        List<OrderDetail> details = order.getOrderDetails();
                        if (details != null && !details.isEmpty()) {
                            for (OrderDetail detail : details) {
                    %>
                    <tr>
                        <td><%=detail.getProductId()%></td>
                        <td><%=detail.getQuantity()%></td>
                        <td><%=String.format("%,.0f", detail.getUnitPrice())%> VNĐ</td>
                        <td><%=String.format("%,.0f", detail.getLineTotal())%> VNĐ</td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr>
                        <td colspan="4" class="text-center text-muted">Chưa có dòng chi tiết.</td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="mt-3 text-end">
                <div><strong>Tạm tính:</strong> <%=String.format("%,.0f", order.getSubtotal())%> VNĐ</div>
                <div><strong>Giảm giá:</strong> <%=String.format("%,.0f", order.getDiscountAmount())%> VNĐ</div>
                <div><strong>Phí giao hàng:</strong> <%=String.format("%,.0f", order.getShippingFee())%> VNĐ</div>
                <div class="fs-5"><strong>Tổng cộng:</strong> <%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</div>
            </div>
        </div>
    </div>
    <% } %>
</main>
</body>
</html>
