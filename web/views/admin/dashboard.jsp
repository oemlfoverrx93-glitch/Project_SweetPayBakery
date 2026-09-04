<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.sweetpay.model.CustomerSpending"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bảng điều khiển Admin - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="admin-page">
<%
    int totalProducts = request.getAttribute("totalProducts") instanceof Integer ? (Integer) request.getAttribute("totalProducts") : 0;
    int totalOrders = request.getAttribute("totalOrders") instanceof Integer ? (Integer) request.getAttribute("totalOrders") : 0;
    int totalUsers = request.getAttribute("totalUsers") instanceof Integer ? (Integer) request.getAttribute("totalUsers") : 0;
    BigDecimal revenue = request.getAttribute("completedRevenue") instanceof BigDecimal ? (BigDecimal) request.getAttribute("completedRevenue") : BigDecimal.ZERO;
    List<CustomerSpending> topCustomerSpendings = (List<CustomerSpending>) request.getAttribute("topCustomerSpendings");
    String spendingStartDate = request.getAttribute("spendingStartDate") instanceof String ? (String) request.getAttribute("spendingStartDate") : "";
    String spendingEndDate = request.getAttribute("spendingEndDate") instanceof String ? (String) request.getAttribute("spendingEndDate") : "";
    String spendingDateNotice = request.getAttribute("spendingDateNotice") instanceof String ? (String) request.getAttribute("spendingDateNotice") : "";
%>
<div class="container-fluid">
    <div class="row">
        <aside class="col-lg-2 sidebar p-3">
            <h5 class="mb-4">SweetPay Admin</h5>
            <a class="active" href="<%=request.getContextPath()%>/admin/dashboard">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/products">Quản lý sản phẩm</a>
            <a href="<%=request.getContextPath()%>/admin/orders">Quản lý đơn hàng</a>
            <a href="<%=request.getContextPath()%>/admin/users">Quản lý khách hàng</a>
            <a href="<%=request.getContextPath()%>/admin/fulfillment">Điều hành & giao hàng</a>
            <a href="<%=request.getContextPath()%>/admin/reconciliation">Đối soát thanh toán</a>
            <a href="<%=request.getContextPath()%>/admin/categories">Danh mục bánh</a>
            <a href="<%=request.getContextPath()%>/admin/vouchers">Mã giảm giá</a>
            <a href="<%=request.getContextPath()%>/admin/staff">Nhân viên</a>
            <a href="<%=request.getContextPath()%>/staff/inventory">Tồn kho</a>
            <a href="<%=request.getContextPath()%>/admin/reports">Báo cáo kinh doanh</a>
            <a href="<%=request.getContextPath()%>/products">Xem trang sản phẩm</a>
            <a href="<%=request.getContextPath()%>/home">Về trang chủ</a>
            <a href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
        </aside>

        <main class="col-lg-10 p-4 p-md-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0">Dashboard</h3>
                <span class="text-muted">Tổng quan hệ thống</span>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <p class="text-muted mb-2">Sản phẩm đang bán</p>
                            <h2 class="mb-0"><%=totalProducts%></h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <p class="text-muted mb-2">Tổng đơn hàng</p>
                            <h2 class="mb-0"><%=totalOrders%></h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <p class="text-muted mb-2">Khách hàng hoạt động</p>
                            <h2 class="mb-0"><%=totalUsers%></h2>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card stat-card">
                <div class="card-body">
                    <h5 class="mb-3">Doanh thu đơn hoàn thành</h5>
                    <h2 class="text-success"><%=String.format("%,.0f", revenue)%> VNĐ</h2>
                </div>
            </div>

            <div class="card stat-card mt-4">
                <div class="card-body">
                    <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-3">
                        <div>
                            <h5 class="mb-1">Top 10 khách hàng chi tiêu cao nhất</h5>
                            <p class="text-muted mb-0">Tính theo các đơn hàng đã hoàn thành trong khoảng ngày đã chọn.</p>
                        </div>
                        <form method="get" action="<%=request.getContextPath()%>/admin/dashboard" class="row g-2 align-items-end">
                            <div class="col-sm-auto">
                                <label class="form-label mb-1">Từ ngày</label>
                                <input type="date" name="startDate" class="form-control"
                                       value="<%=HtmlUtil.escape(spendingStartDate)%>">
                            </div>
                            <div class="col-sm-auto">
                                <label class="form-label mb-1">Đến ngày</label>
                                <input type="date" name="endDate" class="form-control"
                                       value="<%=HtmlUtil.escape(spendingEndDate)%>">
                            </div>
                            <div class="col-sm-auto d-grid">
                                <button type="submit" class="btn btn-primary px-4">Lọc</button>
                            </div>
                        </form>
                    </div>

                    <% if (!spendingDateNotice.isEmpty()) { %>
                    <div class="alert alert-warning py-2"><%=HtmlUtil.escape(spendingDateNotice)%></div>
                    <% } %>

                    <% if (topCustomerSpendings == null || topCustomerSpendings.isEmpty()) { %>
                    <div class="alert alert-info mb-0">Chưa có khách hàng phát sinh đơn hoàn thành trong khoảng thời gian này.</div>
                    <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Khách hàng</th>
                                <th>Email</th>
                                <th>SĐT</th>
                                <th>Số đơn</th>
                                <th>Tổng chi tiêu</th>
                                <th>Đơn đầu</th>
                                <th>Đơn gần nhất</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% int rank = 1; %>
                            <% for (CustomerSpending customer : topCustomerSpendings) { %>
                            <%
                                BigDecimal totalSpent = customer.getTotalSpent() == null ? BigDecimal.ZERO : customer.getTotalSpent();
                                String firstOrderDate = customer.getFirstOrderDate() == null ? "-" : customer.getFirstOrderDate().toLocalDateTime().toLocalDate().toString();
                                String lastOrderDate = customer.getLastOrderDate() == null ? "-" : customer.getLastOrderDate().toLocalDateTime().toLocalDate().toString();
                            %>
                            <tr>
                                <td><strong><%=rank++%></strong></td>
                                <td>
                                    <strong><%=HtmlUtil.escape(customer.getFullName())%></strong>
                                    <div class="text-muted small">ID: <%=customer.getUserId()%></div>
                                </td>
                                <td><%=HtmlUtil.escape(customer.getEmail())%></td>
                                <td><%=HtmlUtil.escapeOr(customer.getPhone(), "-")%></td>
                                <td><span class="badge bg-dark"><%=customer.getOrderCount()%></span></td>
                                <td class="text-success fw-bold"><%=String.format("%,.0f", totalSpent)%> VNĐ</td>
                                <td><%=HtmlUtil.escape(firstOrderDate)%></td>
                                <td><%=HtmlUtil.escape(lastOrderDate)%></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </div>
        </main>
    </div>
</div>
</body>
</html>

