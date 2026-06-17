# Hình 4.x. Use Case Diagram của hệ thống SweetPay Bakery

```mermaid
flowchart LR
    guest["Khách vãng lai"]
    customer["Khách hàng"]
    admin["Quản trị viên"]

    viewHome(("Xem trang chủ"))
    viewProducts(("Xem/tìm kiếm/lọc sản phẩm"))
    viewDetail(("Xem chi tiết sản phẩm"))
    register(("Đăng ký tài khoản"))
    login(("Đăng nhập"))
    manageCart(("Quản lý giỏ hàng"))
    checkout(("Checkout và áp dụng voucher"))
    placeOrder(("Đặt hàng"))
    payVietQR(("Thanh toán chuyển khoản VietQR"))
    viewOrders(("Theo dõi lịch sử/chi tiết đơn"))
    adminDashboard(("Xem dashboard"))
    adminProducts(("Quản lý sản phẩm và tồn kho"))
    adminOrders(("Quản lý đơn hàng/thanh toán"))
    adminUsers(("Quản lý khách hàng"))

    guest --> viewHome
    guest --> viewProducts
    guest --> viewDetail
    guest --> register
    guest --> login
    guest --> manageCart

    customer --> viewHome
    customer --> viewProducts
    customer --> viewDetail
    customer --> manageCart
    customer --> checkout
    checkout --> placeOrder
    placeOrder --> payVietQR
    customer --> viewOrders

    admin --> adminDashboard
    admin --> adminProducts
    admin --> adminOrders
    admin --> adminUsers
    admin --> viewOrders
```

Ghi chú: sơ đồ thể hiện các vai trò thật trong code gồm khách vãng lai, khách hàng đã đăng nhập và quản trị viên. Các use case được suy ra từ servlet/filter/JSP hiện có trong dự án.
