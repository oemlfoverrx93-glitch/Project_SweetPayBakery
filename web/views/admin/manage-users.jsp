<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.User"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Users - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    List<User> users = (List<User>) request.getAttribute("users");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (keyword == null) {
        keyword = "";
    }
    if (selectedStatus == null || selectedStatus.trim().isEmpty()) {
        selectedStatus = "all";
    }
%>
<div class="container-fluid py-4 px-3 px-md-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h3 class="mb-0">Quản lý khách hàng</h3>
        <div class="d-flex gap-2">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-outline-primary">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="btn btn-outline-secondary">Sản phẩm</a>
            <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary">Đơn hàng</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-outline-dark">Đăng xuất</a>
        </div>
    </div>

    <% if ("1".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-success">Đã cập nhật trạng thái tài khoản.</div>
    <% } else if ("0".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-danger">Cập nhật trạng thái tài khoản thất bại.</div>
    <% } %>

    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <form method="get" action="<%=request.getContextPath()%>/admin/users" class="row g-2">
                <div class="col-md-4">
                    <label class="form-label">Tìm kiếm</label>
                    <input type="text" name="q" class="form-control" value="<%=keyword%>"
                           placeholder="Email / SĐT / tên khách">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Trạng thái</label>
                    <select name="status" class="form-select">
                        <option value="all" <%= "all".equals(selectedStatus) ? "selected" : "" %>>Tất cả</option>
                        <option value="active" <%= "active".equals(selectedStatus) ? "selected" : "" %>>Đang hoạt động</option>
                        <option value="inactive" <%= "inactive".equals(selectedStatus) ? "selected" : "" %>>Đã khóa</option>
                    </select>
                </div>
                <div class="col-md-2 d-grid">
                    <label class="form-label invisible">Lọc</label>
                    <button type="submit" class="btn btn-primary">Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <% if (users == null || users.isEmpty()) { %>
    <div class="alert alert-info">Không có khách hàng phù hợp.</div>
    <% } else { %>
    <div class="card shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>Khách hàng</th>
                    <th>Email</th>
                    <th>SĐT</th>
                    <th>Số đơn</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
                </thead>
                <tbody>
                <% for (User user : users) { %>
                <tr>
                    <td><%=user.getUserId()%></td>
                    <td><%=user.getFullName()%></td>
                    <td><%=user.getEmail()%></td>
                    <td><%=user.getPhone() != null ? user.getPhone() : "-"%></td>
                    <td><%=user.getOrderCount()%></td>
                    <td>
                        <% if (user.isStatus()) { %>
                        <span class="badge bg-success">active</span>
                        <% } else { %>
                        <span class="badge bg-secondary">inactive</span>
                        <% } %>
                    </td>
                    <td>
                        <form method="post" action="<%=request.getContextPath()%>/admin/users" class="d-flex gap-2">
                            <input type="hidden" name="userId" value="<%=user.getUserId()%>">
                            <input type="hidden" name="q" value="<%=keyword%>">
                            <input type="hidden" name="statusFilter" value="<%=selectedStatus%>">
                            <% if (user.isStatus()) { %>
                            <input type="hidden" name="newStatus" value="inactive">
                            <button type="submit" class="btn btn-sm btn-outline-danger">Khóa</button>
                            <% } else { %>
                            <input type="hidden" name="newStatus" value="active">
                            <button type="submit" class="btn btn-sm btn-outline-success">Mở khóa</button>
                            <% } %>
                        </form>
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

