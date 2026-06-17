<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.OrderDetail"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page import="com.sweetpay.model.Payment"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String orderStatusLabel(String status) {
        if ("pending".equals(status)) return "Ch&#7901; x&aacute;c nh&#7853;n";
        if ("confirmed".equals(status)) return "&#272;&atilde; x&aacute;c nh&#7853;n";
        if ("preparing".equals(status)) return "&#272;ang chu&#7849;n b&#7883;";
        if ("shipping".equals(status)) return "&#272;ang giao";
        if ("ready_for_pickup".equals(status)) return "Ch&#7901; nh&#7853;n t&#7841;i ti&#7879;m";
        if ("completed".equals(status)) return "Ho&agrave;n t&#7845;t";
        if ("cancelled".equals(status)) return "&#272;&atilde; h&#7911;y";
        return status == null ? "-" : status;
    }

    private String paymentStatusLabel(String status) {
        if ("pending".equals(status)) return "Ch&#7901; thanh to&aacute;n";
        if ("unpaid".equals(status)) return "Ch&#432;a thanh to&aacute;n";
        if ("paid".equals(status)) return "&#272;&atilde; thanh to&aacute;n";
        if ("failed".equals(status)) return "Th&#7845;t b&#7841;i";
        if ("refunded".equals(status)) return "&#272;&atilde; ho&agrave;n ti&#7873;n";
        return status == null ? "-" : status;
    }

    private String receiveMethodLabel(String method) {
        if ("pickup".equals(method)) return "Nh&#7853;n t&#7841;i c&#7917;a h&agrave;ng";
        if ("delivery".equals(method)) return "Giao t&#7853;n n&#417;i";
        return method == null ? "-" : method;
    }

    private String paymentMethodLabel(String method) {
        if ("BANK_TRANSFER".equals(method)) return "Chuy&#7875;n kho&#7843;n";
        if ("COD".equals(method)) return "COD";
        return method == null ? "-" : method;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đơn hàng Admin - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="admin-page">
<%
    Order order = (Order) request.getAttribute("order");
    Payment payment = (Payment) request.getAttribute("payment");
%>
<div class="container py-4">
    <div class="admin-toolbar d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h3 class="mb-0">Chi tiết đơn hàng (admin)</h3>
        <div class="d-flex gap-2">
            <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary">Danh sách đơn</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="btn btn-outline-secondary">Sản phẩm</a>
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-outline-primary">Dashboard</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-outline-dark">Đăng xuất</a>
        </div>
    </div>

    <% if ("1".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-success">Đã cập nhật trạng thái đơn hàng/thanh toán.</div>
    <% } else if ("0".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-danger">Cập nhật thất bại.</div>
    <% } %>

    <% if (order == null) { %>
    <div class="alert alert-warning">Không tìm thấy đơn hàng.</div>
    <% } else { %>
    <div class="row g-3">
        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Thông tin đơn hàng</h5>
                    <p><strong>ID:</strong> <%=order.getOrderId()%></p>
                    <p><strong>Mã đơn:</strong> <%=HtmlUtil.escape(order.getOrderCode())%></p>
                    <p><strong>User ID:</strong> <%=order.getUserId()%></p>
                    <p><strong>Người nhận:</strong> <%=HtmlUtil.escape(order.getRecipientName())%></p>
                    <p><strong>SĐT:</strong> <%=HtmlUtil.escape(order.getRecipientPhone())%></p>
                    <p><strong>Địa chỉ:</strong> <%=HtmlUtil.escape(order.getShippingAddress())%></p>
                    <p><strong>Hình thức nhận:</strong> <%=receiveMethodLabel(order.getReceiveMethod())%></p>
                    <p><strong>Ngày đặt:</strong> <%=order.getOrderDate()%></p>
                    <p><strong>Ghi chú:</strong> <%=HtmlUtil.escapeOr(order.getNote(), "-")%></p>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Cập nhật trạng thái</h5>
                    <form method="post" action="<%=request.getContextPath()%>/admin/orders" class="row g-3">
                        <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                        <input type="hidden" name="from" value="detail">

                        <div class="col-12">
                            <label class="form-label">Trạng thái đơn hàng</label>
                            <select class="form-select" name="orderStatus">
                                <option value="pending" <%= "pending".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("pending")%></option>
                                <option value="confirmed" <%= "confirmed".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("confirmed")%></option>
                                <option value="preparing" <%= "preparing".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("preparing")%></option>
                                <option value="shipping" <%= "shipping".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("shipping")%></option>
                                <option value="ready_for_pickup" <%= "ready_for_pickup".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("ready_for_pickup")%></option>
                                <option value="completed" <%= "completed".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("completed")%></option>
                                <option value="cancelled" <%= "cancelled".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("cancelled")%></option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Trạng thái thanh toán</label>
                            <select class="form-select" name="paymentStatus">
                                <option value="pending" <%= "pending".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("pending")%></option>
                                <option value="unpaid" <%= "unpaid".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("unpaid")%></option>
                                <option value="paid" <%= "paid".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("paid")%></option>
                                <option value="failed" <%= "failed".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("failed")%></option>
                                <option value="refunded" <%= "refunded".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("refunded")%></option>
                            </select>
                        </div>

                        <div class="col-12 d-grid">
                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                        </div>
                    </form>

                    <hr>
                    <h6>Thông tin thanh toán</h6>
                    <% if (payment != null) { %>
                    <p><strong>Phương thức:</strong> <%=paymentMethodLabel(payment.getPaymentMethod())%></p>
                    <p><strong>Trạng thái:</strong> <%=paymentStatusLabel(payment.getPaymentStatus())%></p>
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

    <div class="card shadow-sm mt-3">
        <div class="card-body">
            <h5 class="card-title">Chi tiết sản phẩm trong đơn</h5>
            <div class="table-responsive">
                <table class="table table-bordered align-middle">
                    <thead class="table-light">
                    <tr>
                        <th>Product ID</th>
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
                        <td colspan="4" class="text-center text-muted">Không có dòng chi tiết.</td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="mt-3 text-end">
                <div><strong>Tam tinh:</strong> <%=String.format("%,.0f", order.getSubtotal())%> VNĐ</div>
                <div><strong>Giam gia:</strong> <%=String.format("%,.0f", order.getDiscountAmount())%> VNĐ</div>
                <div><strong>Phi giao hang:</strong> <%=String.format("%,.0f", order.getShippingFee())%> VNĐ</div>
                <div class="fs-5"><strong>Tong cong:</strong> <%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</div>
            </div>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

