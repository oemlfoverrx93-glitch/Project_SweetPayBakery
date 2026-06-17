# Hình 4.x. Activity Diagram quy trình đặt hàng và thanh toán

```mermaid
flowchart TD
    A["Khách xem sản phẩm"] --> B["Thêm sản phẩm vào giỏ hàng"]
    B --> C{"Đã đăng nhập?"}
    C -- "Chưa" --> D["AuthFilter chuyển đến /login"]
    D --> E["Đăng nhập thành công"]
    C -- "Rồi" --> F["Mở trang checkout"]
    E --> F
    F --> G["Nhập thông tin nhận hàng"]
    G --> H{"Nhập voucher?"}
    H -- "Có" --> I["VoucherDAO kiểm tra mã, thời hạn, số lượng"]
    I --> J{"Voucher hợp lệ?"}
    J -- "Không" --> F
    J -- "Có" --> K["Tính giảm giá"]
    H -- "Không" --> L["Tính tạm tính, phí giao hàng, tổng tiền"]
    K --> L
    L --> M["PlaceOrderServlet kiểm tra CSRF, cart, tồn kho"]
    M --> N{"Dữ liệu hợp lệ?"}
    N -- "Không" --> F
    N -- "Có" --> O["OrderDAO.placeOrder chạy transaction"]
    O --> P["Tạo orders, order_details, payments"]
    P --> Q["Trừ tồn kho và lượt voucher"]
    Q --> R{"Phương thức thanh toán"}
    R -- "COD" --> S["Chuyển đến order-success"]
    R -- "BANK_TRANSFER" --> T["PaymentServlet tạo thông tin VietQR"]
    T --> U["Khách chuyển khoản và xác nhận"]
    U --> V["PaymentDAO cập nhật trạng thái paid"]
    V --> S
```

Ghi chú: quy trình này tương ứng với các lớp `CartServlet`, `CheckoutServlet`, `PlaceOrderServlet`, `OrderDAO`, `PaymentServlet`, `PaymentDAO`, `VoucherDAO` và `VietQRUtil`.
