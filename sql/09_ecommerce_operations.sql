USE SweetPayBakery;
GO
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRANSACTION;

-- Additive migration: keeps existing products, accounts and orders.
IF NOT EXISTS (SELECT 1 FROM roles WHERE role_name = 'store_staff')
    INSERT INTO roles(role_name, description) VALUES ('store_staff', N'Nhân viên cửa hàng');
IF NOT EXISTS (SELECT 1 FROM roles WHERE role_name = 'delivery_staff')
    INSERT INTO roles(role_name, description) VALUES ('delivery_staff', N'Nhân viên giao hàng');

DECLARE @checks NVARCHAR(MAX) = N'';
SELECT @checks = @checks + N'ALTER TABLE dbo.orders DROP CONSTRAINT ' + QUOTENAME(name) + N';'
FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.orders')
AND definition LIKE '%order_status%';
EXEC sp_executesql @checks;
ALTER TABLE orders ADD CONSTRAINT CK_orders_workflow CHECK
    (order_status IN ('pending','confirmed','preparing','ready_for_delivery','ready_for_pickup',
                     'shipping','delivery_failed','completed','cancelled'));

IF OBJECT_ID('dbo.deliveries','U') IS NULL
CREATE TABLE deliveries (
    order_id INT PRIMARY KEY REFERENCES orders(order_id),
    driver_id INT NOT NULL REFERENCES users(user_id),
    assigned_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    picked_up_at DATETIME2 NULL,
    delivered_at DATETIME2 NULL,
    failed_at DATETIME2 NULL,
    failure_reason NVARCHAR(500) NULL,
    cod_collected_at DATETIME2 NULL,
    cod_remitted_at DATETIME2 NULL,
    cod_remitted_by INT NULL REFERENCES users(user_id),
    cod_remit_reference NVARCHAR(100) NULL
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_deliveries_driver' AND object_id=OBJECT_ID('deliveries'))
    CREATE INDEX IX_deliveries_driver ON deliveries(driver_id, order_id);

IF OBJECT_ID('dbo.cancellation_requests','U') IS NULL
CREATE TABLE cancellation_requests (
    order_id INT PRIMARY KEY REFERENCES orders(order_id),
    reason NVARCHAR(500) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'requested' CHECK(status IN ('requested','approved','rejected')),
    requested_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    reviewed_at DATETIME2 NULL,
    reviewed_by INT NULL REFERENCES users(user_id),
    review_note NVARCHAR(500) NULL
);

IF OBJECT_ID('dbo.order_events','U') IS NULL
CREATE TABLE order_events (
    event_id INT IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    actor_id INT NULL REFERENCES users(user_id),
    action VARCHAR(40) NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NULL,
    note NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_order_events_order' AND object_id=OBJECT_ID('order_events'))
    CREATE INDEX IX_order_events_order ON order_events(order_id,event_id);

IF OBJECT_ID('dbo.payment_attempts','U') IS NULL
CREATE TABLE payment_attempts (
    reference VARCHAR(64) PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    amount DECIMAL(18,2) NOT NULL CHECK(amount > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','succeeded','failed')),
    transaction_no VARCHAR(100) NULL,
    response_code VARCHAR(10) NULL,
    duplicate_payment BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    expires_at DATETIME2 NOT NULL,
    completed_at DATETIME2 NULL
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_payment_attempts_order' AND object_id=OBJECT_ID('payment_attempts'))
    CREATE INDEX IX_payment_attempts_order ON payment_attempts(order_id,created_at);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_payment_attempts_transaction' AND object_id=OBJECT_ID('payment_attempts'))
    CREATE UNIQUE INDEX UX_payment_attempts_transaction ON payment_attempts(transaction_no)
    WHERE transaction_no IS NOT NULL AND status='succeeded';

IF OBJECT_ID('dbo.payment_reconciliations','U') IS NULL
CREATE TABLE payment_reconciliations (
    reconciliation_id INT IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    kind VARCHAR(30) NOT NULL CHECK(kind IN ('bank_confirm','refund','pickup_cod')),
    amount DECIMAL(18,2) NOT NULL,
    reference NVARCHAR(100) NOT NULL,
    note NVARCHAR(500) NULL,
    actor_id INT NOT NULL REFERENCES users(user_id),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_payment_reconciliation UNIQUE(order_id,kind)
);
IF OBJECT_ID('dbo.inventory_events','U') IS NULL
CREATE TABLE inventory_events (
    event_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id),
    actor_id INT NOT NULL REFERENCES users(user_id),
    quantity_before INT NOT NULL,
    quantity_after INT NOT NULL,
    note NVARCHAR(500) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
COMMIT;
PRINT N'Migration 09: tài khoản nhân viên, giao hàng, thanh toán và đối soát đã sẵn sàng.';
GO
