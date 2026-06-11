<%@page import="java.math.BigDecimal"%>
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
%>
<div class="container-fluid">
    <div class="row">
        <aside class="col-lg-2 sidebar p-3">
            <h5 class="mb-4">SweetPay Admin</h5>
            <a class="active" href="<%=request.getContextPath()%>/admin/dashboard">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/products">Quản lý sản phẩm</a>
            <a href="<%=request.getContextPath()%>/admin/orders">Quản lý đơn hàng</a>
            <a href="<%=request.getContextPath()%>/admin/users">Quản lý khách hàng</a>
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
        </main>
    </div>
</div>
</body>
</html>

