# BÁO CÁO THIẾT KẾ CƠ SỞ DỮ LIỆU

## 1. Trang bìa

- Tên đề tài: Thiết kế CSDL quan hệ cho hệ thống bán bánh SweetPay Bakery
- Nhóm sinh viên: ........................................
- Thành viên 1: ........................................ - MSSV: ........................
- Thành viên 2: ........................................ - MSSV: ........................
- Thành viên 3: ........................................ - MSSV: ........................
- Thành viên 4: ........................................ - MSSV: ........................

## 2. Nội dung

### 2.1. Mô hình cơ sở dữ liệu quan hệ (danh sách các bảng)

1. `roles`
- PK: `role_id`
- FK: Không có

2. `users`
- PK: `user_id`
- FK: `role_id` -> `roles(role_id)`

3. `categories`
- PK: `category_id`
- FK: Không có

4. `products`
- PK: `product_id`
- FK: `category_id` -> `categories(category_id)`

5. `product_images`
- PK: `image_id`
- FK: `product_id` -> `products(product_id)`

6. `vouchers`
- PK: `voucher_id`
- FK: Không có

7. `orders`
- PK: `order_id`
- FK: `user_id` -> `users(user_id)`, `voucher_id` -> `vouchers(voucher_id)`

8. `order_details`
- PK: `order_detail_id`
- FK: `order_id` -> `orders(order_id)`, `product_id` -> `products(product_id)`

9. `inventory`
- PK: `inventory_id`
- FK: `product_id` -> `products(product_id)`

10. `payments`
- PK: `payment_id`
- FK: `order_id` -> `orders(order_id)`

### 2.2. Mô tả chi tiết từng bảng

#### Bảng `roles`

Mô tả: Lưu vai trò người dùng trong hệ thống.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| role_id | INT IDENTITY(1,1) | PK | Mã vai trò |
| role_name | NVARCHAR(50) | NOT NULL, UNIQUE | Tên vai trò (`admin`, `customer`) |
| description | NVARCHAR(255) |  | Mô tả vai trò |

#### Bảng `users`

Mô tả: Lưu thông tin tài khoản người dùng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| user_id | INT IDENTITY(1,1) | PK | Mã người dùng |
| role_id | INT | FK, NOT NULL | Vai trò của người dùng |
| full_name | NVARCHAR(100) | NOT NULL | Họ tên |
| email | NVARCHAR(100) | NOT NULL, UNIQUE | Email đăng nhập |
| phone | NVARCHAR(20) |  | Số điện thoại |
| password_hash | NVARCHAR(255) | NOT NULL | Mật khẩu đã băm |
| address | NVARCHAR(255) |  | Địa chỉ |
| status | BIT | DEFAULT 1 | Trạng thái hoạt động |
| created_at | DATETIME | DEFAULT GETDATE() | Thời gian tạo tài khoản |
| google_sub | NVARCHAR(100) | UNIQUE (filtered, NULL cho phép) | Định danh Google OAuth |
| auth_provider | NVARCHAR(30) |  | Nguồn xác thực (`local`, `google`) |
| avatar_url | NVARCHAR(255) |  | Ảnh đại diện |
| email_verified | BIT | NOT NULL, DEFAULT 0 | Cờ xác minh email |
| last_login_at | DATETIME |  | Thời điểm đăng nhập gần nhất |

#### Bảng `categories`

Mô tả: Danh mục sản phẩm bánh.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| category_id | INT IDENTITY(1,1) | PK | Mã danh mục |
| category_name | NVARCHAR(100) | NOT NULL | Tên danh mục |
| slug | NVARCHAR(100) | UNIQUE | Đường dẫn thân thiện |
| description | NVARCHAR(255) |  | Mô tả danh mục |
| image_url | NVARCHAR(255) |  | Ảnh danh mục |
| status | BIT | DEFAULT 1 | Trạng thái hiển thị |

#### Bảng `products`

Mô tả: Thông tin sản phẩm bán trong hệ thống.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| product_id | INT IDENTITY(1,1) | PK | Mã sản phẩm |
| category_id | INT | FK, NOT NULL | Danh mục của sản phẩm |
| product_name | NVARCHAR(150) | NOT NULL | Tên sản phẩm |
| sku | NVARCHAR(50) | UNIQUE | Mã kho |
| slug | NVARCHAR(150) | UNIQUE | Đường dẫn thân thiện |
| description | NVARCHAR(MAX) |  | Mô tả sản phẩm |
| price | DECIMAL(18,2) | NOT NULL, CHECK (`price >= 0`) | Giá niêm yết |
| sale_price | DECIMAL(18,2) | CHECK (`sale_price >= 0`) | Giá khuyến mãi |
| flavor | NVARCHAR(100) |  | Hương vị |
| size | NVARCHAR(50) |  | Kích thước |
| status | BIT | DEFAULT 1 | Trạng thái hoạt động |
| created_at | DATETIME | DEFAULT GETDATE() | Ngày tạo sản phẩm |

#### Bảng `product_images`

Mô tả: Lưu nhiều ảnh cho một sản phẩm.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| image_id | INT IDENTITY(1,1) | PK | Mã ảnh |
| product_id | INT | FK, NOT NULL | Sản phẩm tương ứng |
| image_url | NVARCHAR(255) | NOT NULL | Đường dẫn ảnh |
| is_main | BIT | DEFAULT 0 | Cờ ảnh chính |
| sort_order | INT | DEFAULT 1 | Thứ tự hiển thị |

#### Bảng `vouchers`

Mô tả: Mã giảm giá áp dụng khi đặt hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| voucher_id | INT IDENTITY(1,1) | PK | Mã voucher |
| code | NVARCHAR(50) | NOT NULL, UNIQUE | Mã áp dụng |
| voucher_name | NVARCHAR(100) | NOT NULL | Tên voucher |
| discount_type | NVARCHAR(20) | NOT NULL, CHECK IN (`percent`, `fixed`) | Loại giảm |
| discount_value | DECIMAL(18,2) | NOT NULL, CHECK (`discount_value > 0`) | Giá trị giảm |
| min_order_value | DECIMAL(18,2) | DEFAULT 0 | Giá trị đơn tối thiểu |
| max_discount | DECIMAL(18,2) |  | Trần giảm tối đa |
| quantity | INT | DEFAULT 0 | Số lượng còn lại |
| start_date | DATETIME |  | Ngày bắt đầu |
| end_date | DATETIME | CHECK (`end_date >= start_date`) | Ngày kết thúc |
| status | BIT | DEFAULT 1 | Trạng thái voucher |

#### Bảng `orders`

Mô tả: Thông tin tổng quát của đơn hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| order_id | INT IDENTITY(1,1) | PK | Mã đơn hàng |
| user_id | INT | FK, NOT NULL | Người đặt hàng |
| voucher_id | INT | FK (NULL cho phép) | Voucher áp dụng |
| order_code | NVARCHAR(50) | NOT NULL, UNIQUE | Mã hiển thị đơn |
| recipient_name | NVARCHAR(100) | NOT NULL | Người nhận |
| recipient_phone | NVARCHAR(20) | NOT NULL | SĐT người nhận |
| shipping_address | NVARCHAR(255) | NOT NULL | Địa chỉ nhận hàng |
| receive_method | NVARCHAR(50) | CHECK IN (`delivery`, `pickup`) | Hình thức nhận |
| receive_time | DATETIME |  | Thời gian nhận dự kiến |
| subtotal | DECIMAL(18,2) | NOT NULL, DEFAULT 0, CHECK (`subtotal >= 0`) | Tiền hàng trước giảm |
| discount_amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0, CHECK (`discount_amount >= 0`) | Tiền giảm giá |
| shipping_fee | DECIMAL(18,2) | NOT NULL, DEFAULT 0, CHECK (`shipping_fee >= 0`) | Phí vận chuyển |
| total_amount | Computed DECIMAL(18,2) | Computed | Tổng tiền = `subtotal - discount_amount + shipping_fee` (chặn âm) |
| order_status | NVARCHAR(30) | DEFAULT `pending`, CHECK danh mục trạng thái | Trạng thái xử lý đơn |
| note | NVARCHAR(255) |  | Ghi chú đơn |
| order_date | DATETIME | DEFAULT GETDATE() | Ngày tạo đơn |

Ghi chú chuẩn hóa:
- `payment_status` đã được tách khỏi `orders`, chỉ lưu tại bảng `payments` để tránh lặp dữ liệu.
- `total_amount` là cột tính toán để tránh lệch dữ liệu khi cập nhật.

#### Bảng `order_details`

Mô tả: Chi tiết từng sản phẩm trong đơn hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| order_detail_id | INT IDENTITY(1,1) | PK | Mã dòng chi tiết |
| order_id | INT | FK, NOT NULL | Thuộc đơn hàng nào |
| product_id | INT | FK, NOT NULL | Sản phẩm nào |
| quantity | INT | NOT NULL, CHECK (`quantity > 0`) | Số lượng |
| unit_price | DECIMAL(18,2) | NOT NULL | Đơn giá tại thời điểm đặt |
| line_total | Computed DECIMAL(18,2) | Computed | Thành tiền dòng = `quantity * unit_price` |

Ràng buộc bổ sung:
- `UNIQUE(order_id, product_id)` để một sản phẩm chỉ xuất hiện một lần trong cùng đơn.

#### Bảng `inventory`

Mô tả: Tồn kho hiện tại của từng sản phẩm.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| inventory_id | INT IDENTITY(1,1) | PK | Mã tồn kho |
| product_id | INT | FK, NOT NULL, UNIQUE | Sản phẩm tương ứng |
| quantity_in_stock | INT | NOT NULL, DEFAULT 0, CHECK (`quantity_in_stock >= 0`) | Số lượng tồn |
| min_stock_level | INT | DEFAULT 5 | Ngưỡng cảnh báo tồn tối thiểu |
| last_restock_date | DATETIME | DEFAULT GETDATE() | Lần nhập kho gần nhất |
| expiration_date | DATETIME |  | Hạn dùng (nếu có) |
| updated_at | DATETIME | DEFAULT GETDATE() | Thời điểm cập nhật |

#### Bảng `payments`

Mô tả: Bản ghi thanh toán cho đơn hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả ý nghĩa |
|---|---|---|---|
| payment_id | INT IDENTITY(1,1) | PK | Mã thanh toán |
| order_id | INT | FK, NOT NULL, UNIQUE | Mỗi đơn tối đa một bản ghi thanh toán |
| payment_method | NVARCHAR(30) | NOT NULL, CHECK IN (`COD`, `BANK_TRANSFER`, `MOMO`, `VNPAY`) | Phương thức thanh toán |
| amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Số tiền thanh toán |
| payment_status | NVARCHAR(30) | NOT NULL, DEFAULT `pending`, CHECK danh mục trạng thái | Trạng thái thanh toán |
| transaction_code | NVARCHAR(100) |  | Mã giao dịch cổng thanh toán |
| paid_at | DATETIME |  | Thời điểm thanh toán thành công |
| created_at | DATETIME | NOT NULL, DEFAULT GETDATE() | Thời điểm tạo bản ghi |

### 2.3. Sơ đồ quan hệ giữa các bảng (ERD)

```mermaid
erDiagram
    roles ||--o{ users : "has"
    categories ||--o{ products : "classifies"
    products ||--o{ product_images : "has"
    users ||--o{ orders : "places"
    vouchers ||--o{ orders : "applies"
    orders ||--o{ order_details : "contains"
    products ||--o{ order_details : "appears_in"
    products ||--o| inventory : "stocks"
    orders ||--o| payments : "has_payment"

    roles {
        int role_id PK
        nvarchar role_name UK
        nvarchar description
    }

    users {
        int user_id PK
        int role_id FK
        nvarchar full_name
        nvarchar email UK
        nvarchar phone
        nvarchar password_hash
        nvarchar address
        bit status
        datetime created_at
        nvarchar google_sub UK
        nvarchar auth_provider
        nvarchar avatar_url
        bit email_verified
        datetime last_login_at
    }

    categories {
        int category_id PK
        nvarchar category_name
        nvarchar slug UK
        nvarchar description
        nvarchar image_url
        bit status
    }

    products {
        int product_id PK
        int category_id FK
        nvarchar product_name
        nvarchar sku UK
        nvarchar slug UK
        decimal price
        decimal sale_price
        bit status
    }

    product_images {
        int image_id PK
        int product_id FK
        nvarchar image_url
        bit is_main
        int sort_order
    }

    vouchers {
        int voucher_id PK
        nvarchar code UK
        nvarchar voucher_name
        nvarchar discount_type
        decimal discount_value
        datetime start_date
        datetime end_date
        bit status
    }

    orders {
        int order_id PK
        int user_id FK
        int voucher_id FK
        nvarchar order_code UK
        decimal subtotal
        decimal discount_amount
        decimal shipping_fee
        decimal total_amount_computed
        nvarchar order_status
        datetime order_date
    }

    order_details {
        int order_detail_id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal unit_price
    }

    inventory {
        int inventory_id PK
        int product_id FK_UK
        int quantity_in_stock
        int min_stock_level
        datetime updated_at
    }

    payments {
        int payment_id PK
        int order_id FK_UK
        nvarchar payment_method
        decimal amount
        nvarchar payment_status
        datetime paid_at
    }
```

### 2.4. Kiểm tra dư thừa và xung đột

1. Không có cột nào có thể suy diễn gây dư thừa theo kiểu lưu lặp độc lập:
- `payment_status` chỉ lưu ở `payments`, không lặp ở `orders`.
- `total_amount` và `line_total` là cột tính toán (computed), không nhập tay nên không gây lệch.

2. Mỗi sự kiện lưu một lần:
- Trạng thái thanh toán lưu một nơi duy nhất (`payments`).
- Mối quan hệ sản phẩm trong đơn được khóa bởi `UNIQUE(order_id, product_id)`.
- Tồn kho mỗi sản phẩm một bản ghi với `UNIQUE(product_id)` ở `inventory`.

3. Cập nhật một nơi duy nhất, tránh xung đột:
- Cập nhật thanh toán chỉ thao tác trên `payments`.
- Cập nhật trạng thái đơn chỉ thao tác trên `orders`.
- Tổng tiền được DB tự tính từ các thành phần tiền gốc.

4. Đánh giá chuẩn hóa:
- Đạt chuẩn 1NF: Thuộc tính nguyên tố, không nhóm lặp trong một cột.
- Đạt chuẩn 2NF: Thuộc tính không khóa phụ thuộc đầy đủ vào khóa chính.
- Đạt chuẩn 3NF: Không có phụ thuộc bắc cầu giữa các thuộc tính không khóa trong cùng bảng (thông tin vai trò tách ra `roles`, thông tin thanh toán tách ra `payments`, chi tiết dòng tách ra `order_details`).

## 3. Tài liệu SQL đi kèm

- Schema gốc: `sql/01_schema.sql`
- Migration chuẩn hóa: `sql/02_normalization_fix.sql`
- Migration tài khoản Google: `sql/03_user_google_migration.sql` (tùy chọn)
- Seed dữ liệu mẫu: `sql/04_product_seed.sql` (tùy chọn)
