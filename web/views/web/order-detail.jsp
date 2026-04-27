<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.OrderDetail"%>
<%@page import="com.sweetpay.model.Payment"%>
<%@page import="com.sweetpay.model.Order"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Detail - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <%
        Order order = (Order) request.getAttribute("order");
        Payment payment = (Payment) request.getAttribute("payment");
    %>

    <% if (order == null) { %>
    <div class="alert alert-warning">
        Order not found. <a href="<%=request.getContextPath()%>/order-history">Back to order history</a>
    </div>
    <% } else { %>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0">Order Detail</h2>
        <a href="<%=request.getContextPath()%>/order-history" class="btn btn-outline-secondary">Back to History</a>
    </div>

    <% if ("1".equals(request.getParameter("success"))) { %>
    <div class="alert alert-success">Order placed successfully.</div>
    <% } %>

    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="card-title">Order Info</h5>
                    <p><strong>Order Code:</strong> <%=order.getOrderCode()%></p>
                    <p><strong>Recipient:</strong> <%=order.getRecipientName()%></p>
                    <p><strong>Phone:</strong> <%=order.getRecipientPhone()%></p>
                    <p><strong>Address:</strong> <%=order.getShippingAddress()%></p>
                    <p><strong>Receive Method:</strong> <%=order.getReceiveMethod()%></p>
                    <p><strong>Order Status:</strong> <span class="badge bg-secondary"><%=order.getOrderStatus()%></span></p>
                    <p><strong>Payment Status:</strong> <span class="badge bg-dark"><%=order.getPaymentStatus()%></span></p>
                    <p><strong>Order Date:</strong> <%=order.getOrderDate()%></p>
                    <p><strong>Note:</strong> <%=order.getNote() != null ? order.getNote() : "-"%></p>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="card-title">Payment Info</h5>
                    <% if (payment != null) { %>
                    <p><strong>Method:</strong> <%=payment.getPaymentMethod()%></p>
                    <p><strong>Status:</strong> <%=payment.getPaymentStatus()%></p>
                    <p><strong>Amount:</strong> <%=payment.getAmount()%> VND</p>
                    <p><strong>Transaction Code:</strong> <%=payment.getTransactionCode() != null ? payment.getTransactionCode() : "-"%></p>
                    <p><strong>Paid At:</strong> <%=payment.getPaidAt() != null ? payment.getPaidAt() : "-"%></p>
                    <% } else { %>
                    <p class="text-muted mb-0">No payment record.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm mt-4">
        <div class="card-body">
            <h5 class="card-title">Order Items</h5>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th>Product ID</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Line Total</th>
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
                        <td><%=detail.getUnitPrice()%> VND</td>
                        <td><%=detail.getLineTotal()%> VND</td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr>
                        <td colspan="4" class="text-center text-muted">No detail rows.</td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="mt-3 text-end">
                <div><strong>Subtotal:</strong> <%=order.getSubtotal()%> VND</div>
                <div><strong>Discount:</strong> <%=order.getDiscountAmount()%> VND</div>
                <div><strong>Shipping:</strong> <%=order.getShippingFee()%> VND</div>
                <div class="fs-5"><strong>Total:</strong> <%=order.getTotalAmount()%> VND</div>
            </div>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

