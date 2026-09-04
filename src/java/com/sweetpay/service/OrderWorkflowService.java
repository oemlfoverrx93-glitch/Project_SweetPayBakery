package com.sweetpay.service;

import com.sweetpay.model.User;
import com.sweetpay.util.*;
import java.sql.*;
import java.util.*;

public class OrderWorkflowService {
    public static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException(message);
    }
    public static void event(Connection c, int orderId, Integer actor, String action, String from, String to, String note) throws SQLException {
        Sql.update(c, "INSERT INTO order_events(order_id,actor_id,action,from_status,to_status,note) VALUES(?,?,?,?,?,?)",
                orderId, actor, action, from, to, note);
    }
    public void act(User actor, int orderId, String action, String target, int driverId, String note, String reference, boolean collected) throws Exception {
        require(actor != null && actor.isStatus(), "Tài khoản không còn hoạt động.");
        note = note == null ? "" : note.trim(); reference = reference == null ? "" : reference.trim();
        require(note.length() <= 500 && reference.length() <= 100, "Ghi chú hoặc mã tham chiếu quá dài.");
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Serialize all order mutations, cancellation and gateway callbacks on the order row.
                Map<String,Object> o = Sql.one(c, "SELECT * FROM orders WITH(UPDLOCK,HOLDLOCK) WHERE order_id=?", orderId);
                require(o != null, "Không tìm thấy đơn hàng.");
                Map<String,Object> p = Sql.one(c, "SELECT * FROM payments WITH(UPDLOCK,HOLDLOCK) WHERE order_id=?", orderId);
                require(p != null, "Đơn hàng chưa có thông tin thanh toán.");
                Map<String,Object> d = Sql.one(c, "SELECT * FROM deliveries WHERE order_id=?", orderId);
                Map<String,Object> cancel = Sql.one(c, "SELECT * FROM cancellation_requests WHERE order_id=?", orderId);
                String role = actor.getRoleName(), state = Sql.string(o,"order_status"), method = Sql.string(o,"receive_method");
                String payMethod = Sql.string(p,"payment_method"), payStatus = Sql.string(p,"payment_status");
                boolean admin = "admin".equals(role), store = admin || "store_staff".equals(role);
                boolean driver = "delivery_staff".equals(role) && d != null && Sql.number(d,"driver_id") == actor.getUserId();
                boolean requested = cancel != null && "requested".equals(Sql.string(cancel,"status"));
                if ("cancel_request".equals(action)) {
                    require(Sql.number(o,"user_id") == actor.getUserId(), "Bạn không có quyền với đơn hàng này.");
                    require("pending".equals(state) && cancel == null, "Chỉ gửi yêu cầu hủy một lần khi đơn chưa được xác nhận.");
                    require(!note.isEmpty(), "Vui lòng nhập lý do hủy.");
                    Sql.update(c, "INSERT INTO cancellation_requests(order_id,reason) VALUES(?,?)", orderId,note);
                } else if ("reject_cancel".equals(action)) {
                    require(admin && requested, "Yêu cầu hủy không còn chờ duyệt.");
                    require(!note.isEmpty(), "Nhập lý do không duyệt yêu cầu hủy.");
                    Sql.update(c, "UPDATE cancellation_requests SET status='rejected',reviewed_at=SYSDATETIME(),reviewed_by=?,review_note=? WHERE order_id=?", actor.getUserId(),note,orderId);
                } else if ("assign".equals(action)) {
                    require(admin && "delivery".equals(method) && Arrays.asList("confirmed","preparing","ready_for_delivery","delivery_failed").contains(state), "Đơn này chưa thể phân công hoặc đã được nhận giao.");
                    require(!requested, "Cần xử lý yêu cầu hủy trước.");
                    require(Sql.one(c, "SELECT u.user_id FROM users u JOIN roles r ON r.role_id=u.role_id WHERE u.user_id=? AND u.status=1 AND r.role_name='delivery_staff'", driverId) != null,
                            "Chọn nhân viên giao hàng đang hoạt động.");
                    if (d == null) Sql.update(c,"INSERT INTO deliveries(order_id,driver_id) VALUES(?,?)",orderId,driverId);
                    else Sql.update(c,"UPDATE deliveries SET driver_id=?,assigned_at=SYSDATETIME() WHERE order_id=?",driverId,orderId);
                    note = "Nhân viên giao hàng #" + driverId + (note.isEmpty() ? "" : ": " + note);
                    require(note.length() <= 500, "Ghi chú quá dài.");
                } else if ("transition".equals(action)) {
                    require(OrderPolicy.next(role,state,method).contains(target), "Bước xử lý không hợp lệ hoặc bạn không có quyền.");
                    require(!requested || "cancelled".equals(target), "Đơn đang có yêu cầu hủy, cần quản trị viên giải quyết trước.");
                    if ("shipping".equals(target) || ("completed".equals(target) && "delivery".equals(method)) || "delivery_failed".equals(target))
                        require((admin || driver) && d != null, "Đơn phải được phân công cho nhân viên giao hàng này.");
                    if ("confirmed".equals(target) || "shipping".equals(target) || "completed".equals(target))
                        require("COD".equals(payMethod) || "paid".equals(payStatus), "Đơn trả trước cần được xác nhận thanh toán.");
                    if ("cancelled".equals(target)) {
                        require(admin && !note.isEmpty(), "Quản trị viên cần nhập lý do hủy.");
                        Sql.update(c, "UPDATE i SET quantity_in_stock=i.quantity_in_stock+od.quantity,updated_at=GETDATE() FROM inventory i JOIN order_details od ON od.product_id=i.product_id WHERE od.order_id=?",orderId);
                        if (o.get("voucher_id") != null) Sql.update(c,"UPDATE vouchers SET quantity=quantity+1 WHERE voucher_id=?",o.get("voucher_id"));
                        if (requested) Sql.update(c,"UPDATE cancellation_requests SET status='approved',reviewed_at=SYSDATETIME(),reviewed_by=?,review_note=? WHERE order_id=?",actor.getUserId(),note,orderId);
                    }
                    if ("shipping".equals(target)) Sql.update(c,"UPDATE deliveries SET picked_up_at=SYSDATETIME() WHERE order_id=?",orderId);
                    if ("delivery_failed".equals(target)) {
                        require(!note.isEmpty(), "Nhập lý do giao chưa thành công.");
                        Sql.update(c,"UPDATE deliveries SET failed_at=SYSDATETIME(),failure_reason=? WHERE order_id=?",note,orderId);
                    }
                    if ("completed".equals(target)) {
                        if ("COD".equals(payMethod) && !"paid".equals(payStatus)) {
                            require(collected, "Xác nhận đã thu đủ tiền COD trước khi hoàn tất.");
                            Sql.update(c,"UPDATE payments SET payment_status='paid',paid_at=SYSDATETIME() WHERE order_id=?",orderId);
                            if ("delivery".equals(method)) Sql.update(c,"UPDATE deliveries SET cod_collected_at=SYSDATETIME() WHERE order_id=?",orderId);
                            else {
                                require(store, "Chỉ nhân viên cửa hàng được thu tiền tại tiệm.");
                                Sql.update(c,"INSERT INTO payment_reconciliations(order_id,kind,amount,reference,note,actor_id) VALUES(?,'pickup_cod',?,?,?,?)",orderId,p.get("amount"),"PICKUP-"+orderId,note,actor.getUserId());
                            }
                        }
                        if (d != null) Sql.update(c,"UPDATE deliveries SET delivered_at=SYSDATETIME() WHERE order_id=?",orderId);
                    }
                    Sql.update(c,"UPDATE orders SET order_status=? WHERE order_id=?",target,orderId);
                } else if ("bank_notice".equals(action)) {
                    require(Sql.number(o,"user_id") == actor.getUserId() && "BANK_TRANSFER".equals(payMethod)
                            && !Arrays.asList("paid","refunded").contains(payStatus) && !"cancelled".equals(state), "Không thể thông báo chuyển khoản cho đơn này.");
                    // A customer report is an audit event, never proof of payment.
                    if (Sql.one(c,"SELECT TOP 1 event_id FROM order_events WHERE order_id=? AND action='bank_notice'",orderId) != null) { c.commit(); return; }
                } else if ("bank_confirm".equals(action)) {
                    require(admin && "BANK_TRANSFER".equals(payMethod) && !Arrays.asList("paid","refunded").contains(payStatus), "Không thể xác nhận chuyển khoản cho đơn này.");
                    require(!reference.isEmpty(), "Nhập mã giao dịch đã đối chiếu trên ngân hàng.");
                    Sql.update(c,"UPDATE payments SET payment_status='paid',paid_at=SYSDATETIME(),transaction_code=? WHERE order_id=?",reference,orderId);
                    Sql.update(c,"INSERT INTO payment_reconciliations(order_id,kind,amount,reference,note,actor_id) VALUES(?,'bank_confirm',?,?,?,?)",orderId,p.get("amount"),reference,note,actor.getUserId());
                } else if ("remit".equals(action)) {
                    require(admin && "COD".equals(payMethod) && d != null && d.get("cod_collected_at") != null && d.get("cod_remitted_at") == null,
                            "Đơn không có khoản COD chờ bàn giao.");
                    require(!reference.isEmpty(), "Nhập mã biên nhận bàn giao tiền.");
                    Sql.update(c,"UPDATE deliveries SET cod_remitted_at=SYSDATETIME(),cod_remitted_by=?,cod_remit_reference=? WHERE order_id=?",actor.getUserId(),reference,orderId);
                } else if ("refund".equals(action)) {
                    require(admin && "cancelled".equals(state) && "paid".equals(payStatus), "Chỉ ghi nhận hoàn tiền cho đơn đã hủy và đã thanh toán.");
                    require(!reference.isEmpty() && !note.isEmpty(), "Nhập mã giao dịch và ghi chú chứng từ hoàn tiền đã thực hiện.");
                    Sql.update(c,"INSERT INTO payment_reconciliations(order_id,kind,amount,reference,note,actor_id) VALUES(?,'refund',?,?,?,?)",orderId,p.get("amount"),reference,note,actor.getUserId());
                    Sql.update(c,"UPDATE payments SET payment_status='refunded' WHERE order_id=?",orderId);
                } else throw new IllegalArgumentException("Thao tác không được hỗ trợ.");
                event(c,orderId,actor.getUserId(),action,state,"transition".equals(action)?target:state,
                        reference.isEmpty()?note:reference + (note.isEmpty()?"":" · " + note.substring(0,Math.min(note.length(),390))));
                c.commit();
            } catch (Exception e) { c.rollback(); throw e; }
        }
    }
    public void adjustStock(User actor, int productId, int quantity, int expected, String reason) throws Exception {
        require(actor != null && ("admin".equals(actor.getRoleName()) || "store_staff".equals(actor.getRoleName())), "Không có quyền cập nhật tồn kho.");
        require(quantity >= 0 && quantity <= 1000000 && reason != null && !reason.trim().isEmpty() && reason.length()<=500, "Nhập số lượng hợp lệ và lý do điều chỉnh.");
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                Map<String,Object> row=Sql.one(c,"SELECT quantity_in_stock FROM inventory WITH(UPDLOCK,HOLDLOCK) WHERE product_id=?",productId);
                require(row != null,"Sản phẩm chưa có dòng tồn kho.");
                int before=Sql.number(row,"quantity_in_stock");
                require(before == expected,"Tồn kho vừa thay đổi do đặt hàng hoặc nhân viên khác. Tải lại trang trước khi lưu.");
                Sql.update(c,"UPDATE inventory SET quantity_in_stock=?,updated_at=GETDATE() WHERE product_id=?",quantity,productId);
                Sql.update(c,"INSERT INTO inventory_events(product_id,actor_id,quantity_before,quantity_after,note) VALUES(?,?,?,?,?)",productId,actor.getUserId(),before,quantity,reason.trim());
                c.commit();
            } catch(Exception e) { c.rollback(); throw e; }
        }
    }
}
