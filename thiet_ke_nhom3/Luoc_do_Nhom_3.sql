-- CSDL: Website bán bánh online (MySQL 8.0, InnoDB, utf8mb4)
CREATE DATABASE IF NOT EXISTS bakery_shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bakery_shop;
CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  last_login_at DATETIME,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(15) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer','admin','store_staff','customer_care') NOT NULL DEFAULT 'customer',
  status ENUM('active','locked') NOT NULL DEFAULT 'active',
  birth_date DATE,
  birth_updated_at DATE,
  avatar_url VARCHAR(255),
  loyalty_points INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE addresses (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  receiver_name VARCHAR(255) NOT NULL,
  receiver_phone VARCHAR(15) NOT NULL,
  province VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  ward VARCHAR(100) NOT NULL,
  street_detail VARCHAR(255) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE categories (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255),
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT 1
) ENGINE=InnoDB;
CREATE TABLE products (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  flavor_options JSON,
  shelf_life_hours SMALLINT UNSIGNED CHECK (shelf_life_hours > 0),
  category_id INT NOT NULL,
  sku VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  ingredients TEXT NOT NULL,
  allergen_warning TEXT NOT NULL,
  storage_guide VARCHAR(255) NOT NULL,
  flavor VARCHAR(100),
  special_type SET('diet','low_sugar','vegan','gluten_free'),
  avg_rating DECIMAL(2,1) NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;
CREATE TABLE product_sizes (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  size_name VARCHAR(50) NOT NULL,
  diameter_cm TINYINT UNSIGNED NOT NULL,
  price DECIMAL(10,2) UNSIGNED NOT NULL CHECK (price > 0),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (product_id, diameter_cm)
) ENGINE=InnoDB;
CREATE TABLE product_images (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  is_cover BOOLEAN NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;
CREATE TABLE inventories (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  stock_date DATE NOT NULL,
  daily_capacity INT NOT NULL DEFAULT 0,
  sold_qty INT NOT NULL DEFAULT 0,
  reserved_qty INT NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (product_id, stock_date),
  CHECK (sold_qty + reserved_qty <= daily_capacity)
) ENGINE=InnoDB;
CREATE TABLE carts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNIQUE,
  session_id VARCHAR(100) UNIQUE,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  CHECK (user_id IS NOT NULL OR session_id IS NOT NULL)
) ENGINE=InnoDB;
CREATE TABLE cart_items (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  flavor VARCHAR(100),
  cart_id INT NOT NULL,
  product_size_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  cake_message VARCHAR(40),
  note VARCHAR(255),
  added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cart_id) REFERENCES carts(id),
  FOREIGN KEY (product_size_id) REFERENCES product_sizes(id)
) ENGINE=InnoDB;
CREATE TABLE vouchers (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE,
  discount_type ENUM('percent','fixed','freeship') NOT NULL,
  discount_value DECIMAL(10,2) UNSIGNED NOT NULL,
  max_discount DECIMAL(10,2) UNSIGNED,
  min_order_amount DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT 0,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  usage_limit INT NOT NULL,
  used_count INT NOT NULL DEFAULT 0,
  per_user_limit INT NOT NULL DEFAULT 1,
  category_id INT,
  status ENUM('active','paused','expired') NOT NULL DEFAULT 'active',
  FOREIGN KEY (category_id) REFERENCES categories(id),
  CHECK (end_date > start_date),
  CHECK (discount_type <> 'percent' OR discount_value <= 100)
) ENGINE=InnoDB;
CREATE TABLE orders (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_code VARCHAR(30) NOT NULL UNIQUE,
  user_id INT NOT NULL,
  voucher_id INT,
  receiver_name VARCHAR(255) NOT NULL,
  receiver_phone VARCHAR(15) NOT NULL,
  delivery_method ENUM('delivery','pickup') NOT NULL DEFAULT 'delivery',
  delivery_address VARCHAR(255),
  delivery_date DATE NOT NULL,
  delivery_time_slot VARCHAR(20) NOT NULL,
  note TEXT,
  subtotal DECIMAL(10,2) NOT NULL,
  shipping_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending_payment','paid_pending_confirm','confirmed','prepared','packed','handed_over','delivering','delivered','cancelled','cancelled_refund_pending') NOT NULL DEFAULT 'pending_payment',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (voucher_id) REFERENCES vouchers(id),
  CHECK (total_amount = subtotal + shipping_fee - discount_amount)
) ENGINE=InnoDB;
CREATE TABLE order_items (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  flavor VARCHAR(100),
  note VARCHAR(255),
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  product_size_id INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  size_name VARCHAR(50) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  cake_message VARCHAR(40),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (product_size_id) REFERENCES product_sizes(id)
) ENGINE=InnoDB;
CREATE TABLE order_status_history (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  from_status VARCHAR(30),
  to_status VARCHAR(30) NOT NULL,
  changed_by INT,
  reason VARCHAR(255),
  changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (changed_by) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE transactions (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  gateway ENUM('VNPAY','MOMO','BANK_CARD','INTL_CARD') NOT NULL,
  gateway_txn_id VARCHAR(100) UNIQUE,
  type ENUM('payment','refund') NOT NULL DEFAULT 'payment',
  amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending','success','failed','cancelled','refund_pending','refunded') NOT NULL DEFAULT 'pending',
  signature_valid BOOLEAN,
  paid_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;
CREATE TABLE shipments (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL UNIQUE,
  carrier ENUM('AHAMOVE','GRAB_EXPRESS','GHTK','OTHER') NOT NULL,
  tracking_code VARCHAR(50) UNIQUE,
  status ENUM('requested','picked_up','delivering','delivered','failed','returned') NOT NULL DEFAULT 'requested',
  ice_pack_sealed BOOLEAN NOT NULL DEFAULT 0,
  shipping_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  handed_over_at DATETIME,
  delivered_at DATETIME,
  proof_image_url VARCHAR(255),
  FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;
CREATE TABLE shipment_events (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  shipment_id INT NOT NULL,
  event_status VARCHAR(30) NOT NULL,
  event_time DATETIME NOT NULL,
  note VARCHAR(255),
  received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (shipment_id) REFERENCES shipments(id),
  UNIQUE (shipment_id, event_status, event_time)
) ENGINE=InnoDB;
CREATE TABLE voucher_usages (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  voucher_id INT NOT NULL,
  user_id INT NOT NULL,
  order_id INT NOT NULL UNIQUE,
  used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (voucher_id) REFERENCES vouchers(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;
CREATE TABLE reviews (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_item_id INT NOT NULL UNIQUE,
  product_id INT NOT NULL,
  user_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content TEXT NOT NULL,
  status ENUM('pending','approved','hidden') NOT NULL DEFAULT 'pending',
  hidden_reason VARCHAR(255),
  moderated_by INT,
  moderated_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_item_id) REFERENCES order_items(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (moderated_by) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE review_images (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  review_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  FOREIGN KEY (review_id) REFERENCES reviews(id)
) ENGINE=InnoDB;
CREATE TABLE review_replies (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  review_id INT NOT NULL UNIQUE,
  staff_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (review_id) REFERENCES reviews(id),
  FOREIGN KEY (staff_id) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE audit_logs (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  actor_id INT NOT NULL,
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id INT NOT NULL,
  reason VARCHAR(255) NOT NULL,
  old_value JSON,
  new_value JSON,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (actor_id) REFERENCES users(id)
) ENGINE=InnoDB;
