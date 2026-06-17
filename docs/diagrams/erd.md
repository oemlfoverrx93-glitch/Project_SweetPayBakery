# Sơ đồ ERD hệ thống SweetPay Bakery

```mermaid
erDiagram
    roles ||--o{ users : "phan_quyen"
    users ||--o{ orders : "dat_hang"
    categories ||--o{ products : "phan_loai"
    products ||--o{ product_images : "co_anh"
    products ||--|| inventory : "co_ton_kho"
    vouchers ||--o{ orders : "duoc_ap_dung"
    orders ||--o{ order_details : "gom_chi_tiet"
    products ||--o{ order_details : "duoc_dat"
    orders ||--|| payments : "thanh_toan"

    roles {
        INT role_id PK
        NVARCHAR role_name UK
        NVARCHAR description
    }

    users {
        INT user_id PK
        INT role_id FK
        NVARCHAR full_name
        NVARCHAR email UK
        NVARCHAR phone
        NVARCHAR password_hash
        NVARCHAR address
        BIT status
        DATETIME created_at
    }

    categories {
        INT category_id PK
        NVARCHAR category_name
        NVARCHAR slug UK
        NVARCHAR description
        NVARCHAR image_url
        BIT status
    }

    products {
        INT product_id PK
        INT category_id FK
        NVARCHAR product_name
        NVARCHAR sku UK
        NVARCHAR slug UK
        NVARCHAR description
        DECIMAL price
        DECIMAL sale_price
        NVARCHAR flavor
        NVARCHAR size
        BIT status
        DATETIME created_at
    }

    product_images {
        INT image_id PK
        INT product_id FK
        NVARCHAR image_url
        BIT is_main
        INT sort_order
    }

    inventory {
        INT inventory_id PK
        INT product_id FK_UK
        INT quantity_in_stock
        INT min_stock_level
        DATETIME last_restock_date
        DATETIME expiration_date
        DATETIME updated_at
    }

    vouchers {
        INT voucher_id PK
        NVARCHAR code UK
        NVARCHAR voucher_name
        NVARCHAR discount_type
        DECIMAL discount_value
        DECIMAL min_order_value
        DECIMAL max_discount
        INT quantity
        DATETIME start_date
        DATETIME end_date
        BIT status
    }

    orders {
        INT order_id PK
        INT user_id FK
        INT voucher_id FK
        NVARCHAR order_code UK
        NVARCHAR recipient_name
        NVARCHAR recipient_phone
        NVARCHAR shipping_address
        NVARCHAR receive_method
        DATETIME receive_time
        DECIMAL subtotal
        DECIMAL discount_amount
        DECIMAL shipping_fee
        DECIMAL total_amount
        NVARCHAR order_status
        NVARCHAR note
        DATETIME order_date
    }

    order_details {
        INT order_detail_id PK
        INT order_id FK
        INT product_id FK
        INT quantity
        DECIMAL unit_price
        DECIMAL line_total
    }

    payments {
        INT payment_id PK
        INT order_id FK_UK
        NVARCHAR payment_method
        DECIMAL amount
        NVARCHAR payment_status
        NVARCHAR transaction_code
        DATETIME paid_at
        DATETIME created_at
    }

    store_bank_account {
        INT account_id PK
        NVARCHAR bank_name
        NVARCHAR account_number
        NVARCHAR account_holder
        NVARCHAR bin_code
        BIT is_default
    }
```

## Ghi chú quan hệ

| Quan hệ | Ý nghĩa |
|---|---|
| `roles` 1 - n `users` | Một vai trò có nhiều người dùng; mỗi người dùng thuộc một vai trò. |
| `users` 1 - n `orders` | Một khách hàng có thể đặt nhiều đơn hàng. |
| `categories` 1 - n `products` | Một danh mục chứa nhiều sản phẩm. |
| `products` 1 - n `product_images` | Một sản phẩm có nhiều ảnh. |
| `products` 1 - 1 `inventory` | Mỗi sản phẩm có một dòng tồn kho. |
| `vouchers` 1 - n `orders` | Một voucher có thể được dùng cho nhiều đơn hàng; đơn hàng có thể không dùng voucher. |
| `orders` 1 - n `order_details` | Một đơn hàng gồm nhiều dòng chi tiết. |
| `products` 1 - n `order_details` | Một sản phẩm có thể xuất hiện trong nhiều chi tiết đơn hàng. |
| `orders` 1 - 1 `payments` | Một đơn hàng có một bản ghi thanh toán. |

`store_bank_account` đang là bảng độc lập, không có khóa ngoại; `PaymentServlet` dùng bảng này để lấy tài khoản ngân hàng mặc định khi sinh VietQR.
