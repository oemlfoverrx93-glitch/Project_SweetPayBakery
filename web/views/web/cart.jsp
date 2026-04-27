<%@page import="com.sweetpay.model.CartItem"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giỏ hàng của bạn - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Be Vietnam Pro', 'Segoe UI', sans-serif;
            background-color: #fffdf4;
        }

        .product-img-cart {
            width: 72px;
            height: 72px;
            object-fit: cover;
            border-radius: 10px;
        }

        .btn-checkout {
            background-color: #ff9a9e;
            color: #fff;
            border: none;
            border-radius: 26px;
            font-weight: 600;
            padding: 10px 24px;
        }

        .btn-checkout:hover {
            background-color: #fb8388;
            color: #fff;
        }

        .quantity-form {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .qty-btn {
            width: 34px;
            height: 34px;
            border: 1px solid #d0d7de;
            background: #fff;
            color: #333;
            border-radius: 10px;
            font-size: 20px;
            font-weight: 700;
            line-height: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .qty-btn:hover {
            background: #f3f4f6;
        }

        .qty-input {
            width: 70px;
            height: 34px;
            text-align: center;
            border: 1px solid #d0d7de;
            border-radius: 10px;
            outline: none;
        }

        .qty-input:focus {
            border-color: #86b7fe;
            box-shadow: 0 0 0 0.2rem rgba(13,110,253,.15);
        }
    </style>
</head>
<body>
<div class="container mt-5 mb-5">
    <h2 class="mb-4 fw-bold text-secondary">Giỏ hàng của bạn</h2>
    <%
        String cartStatus = request.getParameter("status");
        String cartMax = request.getParameter("max");
    %>
    <% if ("stock-limit".equals(cartStatus)) { %>
    <div class="alert alert-warning">Số lượng vượt tồn kho. Bạn chỉ có thể chọn tối đa <strong><%=cartMax != null ? cartMax : "giới hạn hiện tại"%></strong>.</div>
    <% } else if ("out-of-stock".equals(cartStatus)) { %>
    <div class="alert alert-danger">Có sản phẩm vừa hết hàng nên đã được cập nhật lại trong giỏ.</div>
    <% } %>

    <div class="table-responsive bg-white p-4 rounded-4 shadow-sm">
        <table class="table align-middle">
            <thead>
            <tr>
                <th>Sản phẩm</th>
                <th>Đơn giá</th>
                <th style="width: 15%;">Số lượng</th>
                <th>Tổng tiền</th>
                <th class="text-center">Hành động</th>
            </tr>
            </thead>
            <tbody>
            <%
                Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
                double grandTotal = 0;

                if (cart != null && !cart.isEmpty()) {
                    for (CartItem item : cart.values()) {
                        double price = (item.getProduct().getSalePrice() != null)
                                ? item.getProduct().getSalePrice().doubleValue()
                                : item.getProduct().getPrice().doubleValue();

                        double subTotal = item.getQuantity() * price;
                        grandTotal += subTotal;
                        Integer availableStock = item.getProduct().getQuantityInStock();

                        String imagePath = (item.getProduct().getMainImage() != null)
                                ? item.getProduct().getMainImage()
                                : "assets/images/no-image.jpg";
            %>
            <tr>
                <td>
                    <div class="d-flex align-items-center">
                        <img src="<%=request.getContextPath()%>/<%=imagePath%>" class="product-img-cart me-3 border" alt="product">
                        <div>
                            <h6 class="mb-0 fw-bold"><%=item.getProduct().getProductName()%></h6>
                            <small class="text-muted">Vị: <%=item.getProduct().getFlavor() != null ? item.getProduct().getFlavor() : "-"%></small>
                        </div>
                    </div>
                </td>
                <td><%= String.format("%,.0f", price) %> VNĐ</td>
                <td>
                    <form action="<%=request.getContextPath()%>/update-cart-quantity" method="post" class="quantity-form">
                        <input type="hidden" name="id" value="<%=item.getProduct().getProductId()%>">
                        <button type="submit" name="action" value="decrease" class="qty-btn">-</button>
                        <input type="number"
                               name="quantity"
                               value="<%=item.getQuantity()%>"
                               min="1"
                               <% if (availableStock != null && availableStock > 0) { %>max="<%=availableStock%>"<% } %>
                               class="qty-input"
                               onchange="this.form.submit()">
                        <button type="submit" name="action" value="increase" class="qty-btn">+</button>
                    </form>
                </td>
                <td class="fw-bold text-danger"><%= String.format("%,.0f", subTotal) %> VNĐ</td>
                <td class="text-center">
                    <a href="<%=request.getContextPath()%>/remove-from-cart?id=<%=item.getProduct().getProductId()%>"
                       class="btn btn-sm btn-outline-danger"
                       onclick="return confirm('Bạn có chắc muốn xóa món này?')">
                        Xóa
                    </a>
                </td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="5" class="text-center py-5">
                    <img src="https://cdn-icons-png.flaticon.com/512/11329/11329060.png" width="100" class="mb-3 opacity-50" alt="empty-cart"><br>
                    <p class="text-muted">Giỏ hàng của bạn đang trống!</p>
                    <a href="<%=request.getContextPath()%>/home" class="btn btn-primary mt-2">Đi mua bánh ngay</a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <% if (cart != null && !cart.isEmpty()) { %>
        <div class="row mt-4 align-items-center">
            <div class="col-md-6">
                <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-secondary">← Tiếp tục chọn bánh</a>
            </div>
            <div class="col-md-6 text-end">
                <h4 class="mb-3">Tổng thanh toán: <span class="text-danger fw-bold"><%= String.format("%,.0f", grandTotal) %> VNĐ</span></h4>
                <a href="<%=request.getContextPath()%>/checkout" class="btn btn-checkout btn-lg shadow-sm">Thanh toán ngay</a>
            </div>
        </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
