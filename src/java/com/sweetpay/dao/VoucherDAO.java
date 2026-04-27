package com.sweetpay.dao;

import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class VoucherDAO {

    public VoucherValidationResult validateVoucher(String voucherCode, BigDecimal subtotal) {
        try (Connection conn = DBContext.getConnection()) {
            return validateVoucher(conn, voucherCode, subtotal);
        } catch (Exception e) {
            e.printStackTrace();
            return VoucherValidationResult.invalid("Cannot validate voucher right now.");
        }
    }

    public VoucherValidationResult validateVoucher(Connection conn, String voucherCode, BigDecimal subtotal) {
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            return VoucherValidationResult.invalid("Voucher code is empty.");
        }

        if (subtotal == null || subtotal.compareTo(BigDecimal.ZERO) <= 0) {
            return VoucherValidationResult.invalid("Invalid order subtotal.");
        }

        String sql = "SELECT TOP 1 voucher_id, code, discount_type, discount_value, min_order_value, "
                + "max_discount, quantity, start_date, end_date, status "
                + "FROM vouchers WHERE code = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voucherCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return VoucherValidationResult.invalid("Voucher does not exist.");
                }

                boolean status = rs.getBoolean("status");
                if (!status) {
                    return VoucherValidationResult.invalid("Voucher is inactive.");
                }

                int quantity = rs.getInt("quantity");
                if (quantity <= 0) {
                    return VoucherValidationResult.invalid("Voucher is out of stock.");
                }

                Timestamp now = new Timestamp(System.currentTimeMillis());
                Timestamp startDate = rs.getTimestamp("start_date");
                Timestamp endDate = rs.getTimestamp("end_date");
                if (startDate != null && now.before(startDate)) {
                    return VoucherValidationResult.invalid("Voucher is not active yet.");
                }
                if (endDate != null && now.after(endDate)) {
                    return VoucherValidationResult.invalid("Voucher has expired.");
                }

                BigDecimal minOrderValue = rs.getBigDecimal("min_order_value");
                if (minOrderValue != null && subtotal.compareTo(minOrderValue) < 0) {
                    return VoucherValidationResult.invalid("Order does not meet voucher minimum.");
                }

                String discountType = rs.getString("discount_type");
                BigDecimal discountValue = rs.getBigDecimal("discount_value");
                if (discountValue == null || discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                    return VoucherValidationResult.invalid("Voucher discount is invalid.");
                }

                BigDecimal discountAmount;
                if ("percent".equalsIgnoreCase(discountType)) {
                    discountAmount = subtotal.multiply(discountValue)
                            .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
                    BigDecimal maxDiscount = rs.getBigDecimal("max_discount");
                    if (maxDiscount != null && maxDiscount.compareTo(BigDecimal.ZERO) > 0
                            && discountAmount.compareTo(maxDiscount) > 0) {
                        discountAmount = maxDiscount;
                    }
                } else if ("fixed".equalsIgnoreCase(discountType)) {
                    discountAmount = discountValue;
                } else {
                    return VoucherValidationResult.invalid("Voucher discount type is not supported.");
                }

                if (discountAmount.compareTo(subtotal) > 0) {
                    discountAmount = subtotal;
                }
                if (discountAmount.compareTo(BigDecimal.ZERO) < 0) {
                    discountAmount = BigDecimal.ZERO;
                }

                int voucherId = rs.getInt("voucher_id");
                return VoucherValidationResult.valid(voucherId, voucherCode.trim(), discountAmount);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return VoucherValidationResult.invalid("Cannot validate voucher right now.");
        }
    }

    public boolean decreaseVoucherQuantity(Connection conn, int voucherId) {
        if (voucherId <= 0) {
            return false;
        }

        String sql = "UPDATE vouchers SET quantity = quantity - 1 "
                + "WHERE voucher_id = ? AND quantity > 0 AND status = 1 "
                + "AND (start_date IS NULL OR start_date <= GETDATE()) "
                + "AND (end_date IS NULL OR end_date >= GETDATE())";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static class VoucherValidationResult {

        private final boolean valid;
        private final String message;
        private final int voucherId;
        private final String voucherCode;
        private final BigDecimal discountAmount;

        private VoucherValidationResult(boolean valid, String message, int voucherId, String voucherCode, BigDecimal discountAmount) {
            this.valid = valid;
            this.message = message;
            this.voucherId = voucherId;
            this.voucherCode = voucherCode;
            this.discountAmount = discountAmount;
        }

        public static VoucherValidationResult valid(int voucherId, String voucherCode, BigDecimal discountAmount) {
            return new VoucherValidationResult(true, null, voucherId, voucherCode, discountAmount != null ? discountAmount : BigDecimal.ZERO);
        }

        public static VoucherValidationResult invalid(String message) {
            return new VoucherValidationResult(false, message, -1, null, BigDecimal.ZERO);
        }

        public boolean isValid() {
            return valid;
        }

        public String getMessage() {
            return message;
        }

        public int getVoucherId() {
            return voucherId;
        }

        public String getVoucherCode() {
            return voucherCode;
        }

        public BigDecimal getDiscountAmount() {
            return discountAmount;
        }
    }
}
