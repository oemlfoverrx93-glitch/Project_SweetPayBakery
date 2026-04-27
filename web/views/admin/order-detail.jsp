<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.OrderDetail"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page import="com.sweetpay.model.Payment"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Order Detail - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    Order order = (Order) request.getAttribute("order");
    Payment payment = (Payment) request.getAttribute("payment");
%>
<div class="container py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
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
                    <p><strong>Mã đơn:</strong> <%=order.getOrderCode()%></p>
                    <p><strong>User ID:</strong> <%=order.getUserId()%></p>
                    <p><strong>Người nhận:</strong> <%=order.getRecipientName()%></p>
                    <p><strong>SĐT:</strong> <%=order.getRecipientPhone()%></p>
                    <p><strong>Địa chỉ:</strong> <%=order.getShippingAddress()%></p>
                    <p><strong>Hình thức nhận:</strong> <%=order.getReceiveMethod()%></p>
                    <p><strong>Ngày đặt:</strong> <%=order.getOrderDate()%></p>
                    <p><strong>Ghi chú:</strong> <%=order.getNote() != null ? order.getNote() : "-"%></p>
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
                                <option value="pending" <%= "pending".equals(order.getOrderStatus()) ? "selected" : "" %>>pending</option>
                                <option value="confirmed" <%= "confirmed".equals(order.getOrderStatus()) ? "selected" : "" %>>confirmed</option>
                                <option value="preparing" <%= "preparing".equals(order.getOrderStatus()) ? "selected" : "" %>>preparing</option>
                                <option value="shipping" <%= "shipping".equals(order.getOrderStatus()) ? "selected" : "" %>>shipping</option>
                                <option value="ready_for_pickup" <%= "ready_for_pickup".equals(order.getOrderStatus()) ? "selected" : "" %>>ready_for_pickup</option>
                                <option value="completed" <%= "completed".equals(order.getOrderStatus()) ? "selected" : "" %>>completed</option>
                                <option value="cancelled" <%= "cancelled".equals(order.getOrderStatus()) ? "selected" : "" %>>cancelled</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Trạng thái thanh toán</label>
                            <select class="form-select" name="paymentStatus">
                                <option value="pending" <%= "pending".equals(order.getPaymentStatus()) ? "selected" : "" %>>pending</option>
                                <option value="unpaid" <%= "unpaid".equals(order.getPaymentStatus()) ? "selected" : "" %>>unpaid</option>
                                <option value="paid" <%= "paid".equals(order.getPaymentStatus()) ? "selected" : "" %>>paid</option>
                                <option value="failed" <%= "failed".equals(order.getPaymentStatus()) ? "selected" : "" %>>failed</option>
                                <option value="refunded" <%= "refunded".equals(order.getPaymentStatus()) ? "selected" : "" %>>refunded</option>
                            </select>
                        </div>

                        <div class="col-12 d-grid">
                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                        </div>
                    </form>

                    <hr>
                    <h6>Thông tin payment record</h6>
                    <% if (payment != null) { %>
                    <p><strong>Method:</strong> <%=payment.getPaymentMethod()%></p>
                    <p><strong>Status:</strong> <%=payment.getPaymentStatus()%></p>
                    <p><strong>Amount:</strong> <%=String.format("%,.0f", payment.getAmount())%> VNĐ</p>
                    <p><strong>Transaction:</strong> <%=payment.getTransactionCode() != null ? payment.getTransactionCode() : "-"%></p>
                    <p><strong>Paid At:</strong> <%=payment.getPaidAt() != null ? payment.getPaidAt() : "-"%></p>
                    <% } else { %>
                    <p class="text-muted mb-0">Chưa có payment record.</p>
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
                <div><strong>Subtotal:</strong> <%=String.format("%,.0f", order.getSubtotal())%> VNĐ</div>
                <div><strong>Discount:</strong> <%=String.format("%,.0f", order.getDiscountAmount())%> VNĐ</div>
                <div><strong>Shipping:</strong> <%=String.format("%,.0f", order.getShippingFee())%> VNĐ</div>
                <div class="fs-5"><strong>Total:</strong> <%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</div>
            </div>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

