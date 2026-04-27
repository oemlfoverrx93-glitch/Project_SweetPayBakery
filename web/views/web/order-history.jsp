<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order History - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0">Order History</h2>
        <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-secondary">Back to Home</a>
    </div>

    <% if ("forbidden".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">You do not have permission to view that order.</div>
    <% } %>

    <%
        List<Order> orders = (List<Order>) request.getAttribute("orders");
    %>

    <% if (orders == null || orders.isEmpty()) { %>
    <div class="alert alert-info">
        No orders found.
    </div>
    <% } else { %>
    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Order Code</th>
                        <th>Order Date</th>
                        <th>Total</th>
                        <th>Order Status</th>
                        <th>Payment Status</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Order order : orders) { %>
                    <tr>
                        <td><%=order.getOrderCode()%></td>
                        <td><%=order.getOrderDate()%></td>
                        <td><%=order.getTotalAmount()%> VND</td>
                        <td><span class="badge bg-secondary"><%=order.getOrderStatus()%></span></td>
                        <td><span class="badge bg-dark"><%=order.getPaymentStatus()%></span></td>
                        <td>
                            <a class="btn btn-sm btn-primary"
                               href="<%=request.getContextPath()%>/order-detail?id=<%=order.getOrderId()%>">
                                View Detail
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
</div>
</body>
</html>

