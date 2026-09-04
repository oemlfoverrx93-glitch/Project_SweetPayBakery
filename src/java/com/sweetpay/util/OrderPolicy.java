package com.sweetpay.util;

import java.util.*;

/** The same transition rules drive the UI and server-side enforcement. */
public final class OrderPolicy {
    private OrderPolicy() { }
    public static List<String> next(String role, String status, String method) {
        boolean store = "admin".equals(role) || "store_staff".equals(role);
        boolean driver = "admin".equals(role) || "delivery_staff".equals(role);
        List<String> result = new ArrayList<>();
        if (store) {
            if ("pending".equals(status)) result.add("confirmed");
            if ("confirmed".equals(status)) result.add("preparing");
            if ("preparing".equals(status)) result.add("pickup".equals(method) ? "ready_for_pickup" : "ready_for_delivery");
            if ("ready_for_pickup".equals(status) && "pickup".equals(method)) result.add("completed");
            if ("delivery_failed".equals(status)) result.add("ready_for_delivery");
        }
        if (driver && "delivery".equals(method)) {
            if ("ready_for_delivery".equals(status)) result.add("shipping");
            if ("shipping".equals(status)) { result.add("completed"); result.add("delivery_failed"); }
        }
        if ("admin".equals(role) && Arrays.asList("pending","confirmed","preparing","ready_for_delivery","ready_for_pickup","delivery_failed").contains(status))
            result.add("cancelled");
        return result;
    }
    public static String label(String value) {
        if (value == null) return "—";
        switch (value) {
            case "pending": return "Chờ xác nhận";
            case "confirmed": return "Đã xác nhận";
            case "preparing": return "Đang chuẩn bị";
            case "ready_for_delivery": return "Sẵn sàng giao";
            case "ready_for_pickup": return "Sẵn sàng nhận tại tiệm";
            case "shipping": return "Đang giao";
            case "delivery_failed": return "Giao chưa thành công";
            case "completed": return "Hoàn tất";
            case "cancelled": return "Đã hủy";
            case "requested": return "Chờ duyệt hủy";
            case "approved": return "Đã duyệt hủy";
            case "rejected": return "Không duyệt hủy";
            case "paid": return "Đã thanh toán";
            case "unpaid": return "Chưa thanh toán";
            case "failed": return "Thanh toán thất bại";
            case "refunded": return "Đã hoàn tiền";
            case "succeeded": return "Thành công";
            case "store_staff": return "Nhân viên cửa hàng";
            case "delivery_staff": return "Nhân viên giao hàng";
            case "admin": return "Quản trị viên";
            case "customer": return "Khách hàng";
            case "delivery": return "Giao tận nơi";
            case "pickup": return "Nhận tại tiệm";
            case "BANK_TRANSFER": return "Chuyển khoản";
            case "VNPAY": return "VNPAY Sandbox";
            case "COD": return "Thanh toán khi nhận bánh";
            case "cancel_request": return "Yêu cầu hủy đơn";
            case "reject_cancel": return "Từ chối yêu cầu hủy";
            case "assign": return "Phân công giao hàng";
            case "transition": return "Cập nhật tiến độ";
            case "bank_confirm": return "Đối soát chuyển khoản";
            case "bank_notice": return "Khách thông báo chuyển khoản";
            case "remit": return "Bàn giao tiền COD";
            case "refund": return "Ghi nhận hoàn tiền";
            case "gateway": return "Kết quả cổng thanh toán";
            default: return value;
        }
    }
}
