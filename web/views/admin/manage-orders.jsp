<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Orders - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String selectedOrderStatus = (String) request.getAttribute("selectedOrderStatus");
    String selectedPaymentStatus = (String) request.getAttribute("selectedPaymentStatus");
    String keyword = (String) request.getAttribute("keyword");
    if (selectedOrderStatus == null || selectedOrderStatus.trim().isEmpty()) {
        selectedOrderStatus = "all";
    }
    if (selectedPaymentStatus == null || selectedPaymentStatus.trim().isEmpty()) {
        selectedPaymentStatus = "all";
    }
    if (keyword == null) {
        keyword = "";
    }
%>
<div class="container-fluid py-4 px-3 px-md-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h3 class="mb-0">Quản lý đơn hàng</h3>
        <div class="d-flex gap-2">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-outline-primary">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="btn btn-outline-secondary">Sản phẩm</a>
            <a href="<%=request.getContextPath()%>/admin/users" class="btn btn-outline-secondary">Khách hàng</a>
            <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-secondary">Trang chủ</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-outline-dark">Đăng xuất</a>
        </div>
    </div>

    <% if ("1".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-success">Đã cập nhật trạng thái đơn hàng/thanh toán.</div>
    <% } else if ("0".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-danger">Cập nhật thất bại. Vui lòng kiểm tra lại trạng thái.</div>
    <% } %>

    <% if ("invalid-id".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">Mã đơn không hợp lệ.</div>
    <% } else if ("not-found".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">Không tìm thấy đơn hàng.</div>
    <% } %>

    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <form method="get" action="<%=request.getContextPath()%>/admin/orders" class="row g-2">
                <div class="col-md-3">
                    <label class="form-label">Trạng thái đơn</label>
                    <select name="orderStatus" class="form-select">
                        <option value="all" <%= "all".equals(selectedOrderStatus) ? "selected" : "" %>>Tất cả</option>
                        <option value="pending" <%= "pending".equals(selectedOrderStatus) ? "selected" : "" %>>pending</option>
                        <option value="confirmed" <%= "confirmed".equals(selectedOrderStatus) ? "selected" : "" %>>confirmed</option>
                        <option value="preparing" <%= "preparing".equals(selectedOrderStatus) ? "selected" : "" %>>preparing</option>
                        <option value="shipping" <%= "shipping".equals(selectedOrderStatus) ? "selected" : "" %>>shipping</option>
                        <option value="ready_for_pickup" <%= "ready_for_pickup".equals(selectedOrderStatus) ? "selected" : "" %>>ready_for_pickup</option>
                        <option value="completed" <%= "completed".equals(selectedOrderStatus) ? "selected" : "" %>>completed</option>
                        <option value="cancelled" <%= "cancelled".equals(selectedOrderStatus) ? "selected" : "" %>>cancelled</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Trạng thái thanh toán</label>
                    <select name="paymentStatus" class="form-select">
                        <option value="all" <%= "all".equals(selectedPaymentStatus) ? "selected" : "" %>>Tất cả</option>
                        <option value="pending" <%= "pending".equals(selectedPaymentStatus) ? "selected" : "" %>>pending</option>
                        <option value="unpaid" <%= "unpaid".equals(selectedPaymentStatus) ? "selected" : "" %>>unpaid</option>
                        <option value="paid" <%= "paid".equals(selectedPaymentStatus) ? "selected" : "" %>>paid</option>
                        <option value="failed" <%= "failed".equals(selectedPaymentStatus) ? "selected" : "" %>>failed</option>
                        <option value="refunded" <%= "refunded".equals(selectedPaymentStatus) ? "selected" : "" %>>refunded</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tìm kiếm</label>
                    <input type="text" name="q" class="form-control" value="<%=keyword%>"
                           placeholder="Mã đơn / người nhận / SĐT">
                </div>
                <div class="col-md-2 d-grid">
                    <label class="form-label invisible">Lọc</label>
                    <button type="submit" class="btn btn-primary">Lọc dữ liệu</button>
                </div>
            </form>
        </div>
    </div>

    <% if (orders == null || orders.isEmpty()) { %>
    <div class="alert alert-info mb-0">Không có đơn hàng phù hợp bộ lọc.</div>
    <% } else { %>
    <div class="card shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>Mã đơn</th>
                    <th>Người nhận</th>
                    <th>SĐT</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái đơn</th>
                    <th>Trạng thái thanh toán</th>
                    <th>Ngày đặt</th>
                    <th>Cập nhật nhanh</th>
                    <th>Chi tiết</th>
                </tr>
                </thead>
                <tbody>
                <% for (Order order : orders) { %>
                <tr>
                    <td><%=order.getOrderId()%></td>
                    <td><strong><%=order.getOrderCode()%></strong></td>
                    <td><%=order.getRecipientName()%></td>
                    <td><%=order.getRecipientPhone()%></td>
                    <td><%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</td>
                    <td><span class="badge bg-primary"><%=order.getOrderStatus()%></span></td>
                    <td><span class="badge bg-dark"><%=order.getPaymentStatus()%></span></td>
                    <td><%=order.getOrderDate()%></td>
                    <td style="min-width: 360px;">
                        <form method="post" action="<%=request.getContextPath()%>/admin/orders" class="row g-2">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <input type="hidden" name="from" value="list">
                            <input type="hidden" name="orderStatusFilter" value="<%=selectedOrderStatus%>">
                            <input type="hidden" name="paymentStatusFilter" value="<%=selectedPaymentStatus%>">
                            <input type="hidden" name="q" value="<%=keyword%>">

                            <div class="col-md-5">
                                <select class="form-select form-select-sm" name="orderStatus">
                                    <option value="pending" <%= "pending".equals(order.getOrderStatus()) ? "selected" : "" %>>pending</option>
                                    <option value="confirmed" <%= "confirmed".equals(order.getOrderStatus()) ? "selected" : "" %>>confirmed</option>
                                    <option value="preparing" <%= "preparing".equals(order.getOrderStatus()) ? "selected" : "" %>>preparing</option>
                                    <option value="shipping" <%= "shipping".equals(order.getOrderStatus()) ? "selected" : "" %>>shipping</option>
                                    <option value="ready_for_pickup" <%= "ready_for_pickup".equals(order.getOrderStatus()) ? "selected" : "" %>>ready_for_pickup</option>
                                    <option value="completed" <%= "completed".equals(order.getOrderStatus()) ? "selected" : "" %>>completed</option>
                                    <option value="cancelled" <%= "cancelled".equals(order.getOrderStatus()) ? "selected" : "" %>>cancelled</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <select class="form-select form-select-sm" name="paymentStatus">
                                    <option value="pending" <%= "pending".equals(order.getPaymentStatus()) ? "selected" : "" %>>pending</option>
                                    <option value="unpaid" <%= "unpaid".equals(order.getPaymentStatus()) ? "selected" : "" %>>unpaid</option>
                                    <option value="paid" <%= "paid".equals(order.getPaymentStatus()) ? "selected" : "" %>>paid</option>
                                    <option value="failed" <%= "failed".equals(order.getPaymentStatus()) ? "selected" : "" %>>failed</option>
                                    <option value="refunded" <%= "refunded".equals(order.getPaymentStatus()) ? "selected" : "" %>>refunded</option>
                                </select>
                            </div>
                            <div class="col-md-3 d-grid">
                                <button type="submit" class="btn btn-sm btn-primary">Lưu</button>
                            </div>
                        </form>
                    </td>
                    <td>
                        <a class="btn btn-sm btn-outline-dark" href="<%=request.getContextPath()%>/admin/order/detail?id=<%=order.getOrderId()%>">Xem</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

