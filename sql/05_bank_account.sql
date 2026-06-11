USE SweetPayBakery;
GO

-- Tạo bảng nếu chưa có
IF OBJECT_ID('dbo.store_bank_account', 'U') IS NULL
BEGIN
    CREATE TABLE store_bank_account (
        account_id INT IDENTITY(1,1) PRIMARY KEY,
        bank_name NVARCHAR(100) NOT NULL,
        account_number NVARCHAR(50) NOT NULL,
        account_holder NVARCHAR(100) NOT NULL,
        bin_code NVARCHAR(20) NOT NULL,
        is_default BIT DEFAULT 1
    );
END
GO

-- Xóa dữ liệu cũ nếu có và thêm lại đúng thông tin
DELETE FROM store_bank_account;

INSERT INTO store_bank_account (bank_name, account_number, account_holder, bin_code, is_default)
VALUES (
    N'Ngân hàng Quân đội (MB Bank)',
    '240220060903',
    N'Nguyễn Thị Tuyết Mai',
    '970422',
    1
);
GO

PRINT 'Store bank account updated successfully.';
GO
