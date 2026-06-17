<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.Order"%>
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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý đơn hàng - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="admin-page">
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
    <div class="admin-toolbar d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
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
                        <option value="pending" <%= "pending".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("pending")%></option>
                        <option value="confirmed" <%= "confirmed".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("confirmed")%></option>
                        <option value="preparing" <%= "preparing".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("preparing")%></option>
                        <option value="shipping" <%= "shipping".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("shipping")%></option>
                        <option value="ready_for_pickup" <%= "ready_for_pickup".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("ready_for_pickup")%></option>
                        <option value="completed" <%= "completed".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("completed")%></option>
                        <option value="cancelled" <%= "cancelled".equals(selectedOrderStatus) ? "selected" : "" %>><%=orderStatusLabel("cancelled")%></option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Trạng thái thanh toán</label>
                    <select name="paymentStatus" class="form-select">
                        <option value="all" <%= "all".equals(selectedPaymentStatus) ? "selected" : "" %>>Tất cả</option>
                        <option value="pending" <%= "pending".equals(selectedPaymentStatus) ? "selected" : "" %>><%=paymentStatusLabel("pending")%></option>
                        <option value="unpaid" <%= "unpaid".equals(selectedPaymentStatus) ? "selected" : "" %>><%=paymentStatusLabel("unpaid")%></option>
                        <option value="paid" <%= "paid".equals(selectedPaymentStatus) ? "selected" : "" %>><%=paymentStatusLabel("paid")%></option>
                        <option value="failed" <%= "failed".equals(selectedPaymentStatus) ? "selected" : "" %>><%=paymentStatusLabel("failed")%></option>
                        <option value="refunded" <%= "refunded".equals(selectedPaymentStatus) ? "selected" : "" %>><%=paymentStatusLabel("refunded")%></option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tìm kiếm</label>
                    <input type="text" name="q" class="form-control" value="<%=HtmlUtil.escape(keyword)%>"
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
                    <td><strong><%=HtmlUtil.escape(order.getOrderCode())%></strong></td>
                    <td><%=HtmlUtil.escape(order.getRecipientName())%></td>
                    <td><%=HtmlUtil.escape(order.getRecipientPhone())%></td>
                    <td><%=String.format("%,.0f", order.getTotalAmount())%> VNĐ</td>
                    <td><span class="badge bg-primary"><%=orderStatusLabel(order.getOrderStatus())%></span></td>
                    <td><span class="badge bg-dark"><%=paymentStatusLabel(order.getPaymentStatus())%></span></td>
                    <td><%=order.getOrderDate()%></td>
                    <td class="admin-quick-update">
                        <form method="post" action="<%=request.getContextPath()%>/admin/orders" class="row g-2">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <input type="hidden" name="from" value="list">
                            <input type="hidden" name="orderStatusFilter" value="<%=HtmlUtil.escape(selectedOrderStatus)%>">
                            <input type="hidden" name="paymentStatusFilter" value="<%=HtmlUtil.escape(selectedPaymentStatus)%>">
                            <input type="hidden" name="q" value="<%=HtmlUtil.escape(keyword)%>">

                            <div class="col-md-5">
                                <select class="form-select form-select-sm" name="orderStatus">
                                    <option value="pending" <%= "pending".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("pending")%></option>
                                    <option value="confirmed" <%= "confirmed".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("confirmed")%></option>
                                    <option value="preparing" <%= "preparing".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("preparing")%></option>
                                    <option value="shipping" <%= "shipping".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("shipping")%></option>
                                    <option value="ready_for_pickup" <%= "ready_for_pickup".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("ready_for_pickup")%></option>
                                    <option value="completed" <%= "completed".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("completed")%></option>
                                    <option value="cancelled" <%= "cancelled".equals(order.getOrderStatus()) ? "selected" : "" %>><%=orderStatusLabel("cancelled")%></option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <select class="form-select form-select-sm" name="paymentStatus">
                                    <option value="pending" <%= "pending".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("pending")%></option>
                                    <option value="unpaid" <%= "unpaid".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("unpaid")%></option>
                                    <option value="paid" <%= "paid".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("paid")%></option>
                                    <option value="failed" <%= "failed".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("failed")%></option>
                                    <option value="refunded" <%= "refunded".equals(order.getPaymentStatus()) ? "selected" : "" %>><%=paymentStatusLabel("refunded")%></option>
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

