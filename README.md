---

## Tính năng chính

### Phía khách hàng
| Tính năng | Mô tả |
|---|---|
| Trang chủ | Hiển thị sản phẩm nổi bật, danh mục bánh |
| Danh sách sản phẩm | Lọc theo danh mục, xem chi tiết sản phẩm |
| Giỏ hàng | Thêm, cập nhật số lượng, xóa sản phẩm |
| Thanh toán | Nhập địa chỉ nhận hàng, chọn hình thức nhận, áp mã voucher |
| Lịch sử đơn hàng | Xem danh sách và chi tiết đơn đã đặt |
| Đăng ký / Đăng nhập | Xác thực local hoặc qua **Google OAuth** |
| Giới thiệu | Trang thông tin về tiệm bánh |

### Phía quản trị (Admin)
| Tính năng | Mô tả |
|---|---|
| Dashboard | Thống kê doanh thu, đơn hàng mới nhất |
| Quản lý sản phẩm | Thêm / sửa / xóa sản phẩm, upload ảnh, quản lý tồn kho |
| Quản lý đơn hàng | Xem danh sách, duyệt/hủy đơn, xem chi tiết |
| Quản lý người dùng | Xem danh sách tài khoản, đổi trạng thái |

---

## Kiến trúc dự án

```
SweetBakery/
├── src/
│   └── java/com/sweetpay/
│       ├── controller/      # Servlet (Controllers)
│       ├── dao/             # Data Access Objects
│       ├── model/           # Java Beans (POJO)
│       └── util/            # Tiện ích dùng chung
├── web/
│   ├── views/
│   │   ├── web/             # JSP phía khách hàng
│   │   └── admin/           # JSP phía quản trị
│   ├── assets/              # CSS, JS, images
│   └── WEB-INF/
│       └── web.xml
├── sql/
│   ├── 01_schema.sql              # Tạo CSDL
│   ├── 02_normalization_fix.sql   # Migration chuẩn hóa
│   ├── 03_user_google_migration.sql # Google OAuth migration
│   └── 04_product_seed.sql        # Dữ liệu mẫu
├── build.xml                      # Apache Ant build script
└── BAO_CAO_THIET_KE_CSDL.md      # Báo cáo thiết kế CSDL
```

---

## Cơ sở dữ liệu

Hệ thống sử dụng **Microsoft SQL Server** với 10 bảng chính:

| Bảng | Mô tả |
|---|---|
| `roles` | Vai trò người dùng (admin / customer) |
| `users` | Tài khoản người dùng, hỗ trợ Google OAuth |
| `categories` | Danh mục sản phẩm |
| `products` | Thông tin sản phẩm bánh |
| `product_images` | Ảnh sản phẩm (nhiều ảnh / sản phẩm) |
| `vouchers` | Mã giảm giá |
| `orders` | Đơn hàng |
| `order_details` | Chi tiết dòng sản phẩm trong đơn |
| `inventory` | Tồn kho |
| `payments` | Bản ghi thanh toán |

> Xem chi tiết thiết kế tại [`BAO_CAO_THIET_KE_CSDL.md`](BAO_CAO_THIET_KE_CSDL.md) và sơ đồ ERD tại [`BAO_CAO_ERD.png`](BAO_CAO_ERD.png).

---

## ⚙️ Yêu cầu môi trường

| Thành phần | Phiên bản khuyến nghị |
|---|---|
| Java JDK | 11 hoặc 17 |
| Apache Tomcat | 9.x / 10.x |
| Microsoft SQL Server | 2019+ (hoặc SQL Server Express) |
| NetBeans IDE | 17+ (hoặc IDE Java EE tương thích Ant) |
| Microsoft JDBC Driver | 12.x |

---

## Hướng dẫn cài đặt

### 1. Clone dự án

```bash
git clone <repository-url>
cd SweetBakery
```

### 2. Khởi tạo cơ sở dữ liệu

Chạy các script SQL theo thứ tự trong **SQL Server Management Studio (SSMS)**:

```sql
-- 1. Tạo schema
-- Chạy: sql/01_schema.sql

-- 2. Áp dụng migration chuẩn hóa
-- Chạy: sql/02_normalization_fix.sql

-- 3. (Tùy chọn) Migration Google OAuth
-- Chạy: sql/03_user_google_migration.sql

-- 4. (Tùy chọn) Nạp dữ liệu mẫu
-- Chạy: sql/04_product_seed.sql
```

### 3. Cấu hình kết nối CSDL

Chỉnh sửa file cấu hình kết nối (thường nằm trong `src/java/com/sweetpay/util/`) với thông tin SQL Server của bạn:

```properties
db.url=jdbc:sqlserver://localhost:1433;databaseName=SweetBakery;encrypt=true;trustServerCertificate=true
db.username=sa
db.password=your_password
```

### 4. Cấu hình Google OAuth (tùy chọn)

Tạo project trên [Google Cloud Console](https://console.cloud.google.com/) và lấy **Client ID** / **Client Secret**, sau đó cập nhật vào file cấu hình tương ứng trong dự án.

### 5. Build & Deploy

**Dùng NetBeans:**
- Mở project → **Clean and Build** → **Deploy** lên Tomcat.

**Dùng Apache Ant:**
```bash
ant clean build
# Sau đó copy dist/*.war vào thư mục webapps của Tomcat
```

### 6. Truy cập ứng dụng

```
http://localhost:8080/SweetBakery/
```

---

## Tài khoản mặc định

> Đổi mật khẩu ngay sau khi khởi chạy lần đầu.

| Vai trò | Email | Mật khẩu mặc định |
|---|---|---|
| Admin | admin@sweetbakery.com | _(xem seed SQL)_ |
| Customer | _(đăng ký mới)_ | — |

---

## Các Servlet chính

| Servlet | URL Pattern | Chức năng |
|---|---|---|
| `HomeServlet` | `/home` | Trang chủ |
| `ProductServlet` | `/products` | Danh sách sản phẩm |
| `ProductDetailServlet` | `/product-detail` | Chi tiết sản phẩm |
| `CartServlet` | `/cart` | Giỏ hàng |
| `CheckoutServlet` | `/checkout` | Thanh toán |
| `PlaceOrderServlet` | `/place-order` | Xác nhận đặt hàng |
| `OrderHistoryServlet` | `/order-history` | Lịch sử đơn hàng |
| `LoginServlet` | `/login` | Đăng nhập |
| `RegisterServlet` | `/register` | Đăng ký |
| `GoogleLoginServlet` | `/auth/google` | Đăng nhập Google |
| `AdminDashboardServlet` | `/admin/dashboard` | Bảng điều khiển admin |
| `AdminProductServlet` | `/admin/products` | Quản lý sản phẩm |
| `AdminOrderServlet` | `/admin/order` | Chi tiết đơn hàng (admin) |
| `AdminOrdersServlet` | `/admin/orders` | Danh sách đơn hàng (admin) |
| `AdminUserServlet` | `/admin/users` | Quản lý người dùng |

---

## Đóng góp

1. Fork repository
2. Tạo branch mới: `git checkout -b feature/ten-tinh-nang`
3. Commit thay đổi: `git commit -m "feat: mô tả thay đổi"`
4. Push branch: `git push origin feature/ten-tinh-nang`
5. Tạo Pull Request

---
