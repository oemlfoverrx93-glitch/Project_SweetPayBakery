package com.sweetpay.service;

import com.sweetpay.util.*;
import java.math.BigDecimal;
import java.sql.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import static com.sweetpay.service.OrderWorkflowService.require;

public class GatewayPaymentService {
    public String start(int orderId,int customerId,String ip) throws Exception {
        require(VnpayConfig.configured(),"Thanh toán VNPAY thử nghiệm chưa được cấu hình. Vui lòng chọn phương thức khác hoặc liên hệ cửa hàng.");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                Map<String,Object> o=Sql.one(c,"SELECT * FROM orders WITH(UPDLOCK,HOLDLOCK) WHERE order_id=? AND user_id=?",orderId,customerId);
                require(o!=null,"Không tìm thấy đơn hàng của bạn.");
                Map<String,Object> p=Sql.one(c,"SELECT * FROM payments WITH(UPDLOCK,HOLDLOCK) WHERE order_id=?",orderId);
                require(p!=null && "VNPAY".equals(Sql.string(p,"payment_method")) && !Arrays.asList("paid","refunded").contains(Sql.string(p,"payment_status"))
                        && !Arrays.asList("cancelled","completed").contains(Sql.string(o,"order_status")),"Đơn không còn có thể thanh toán.");
                require(Sql.one(c,"SELECT order_id FROM cancellation_requests WHERE order_id=? AND status='requested'",orderId)==null,"Đơn đang chờ duyệt hủy.");
                BigDecimal amount=(BigDecimal)p.get("amount");
                require(amount.signum()>0 && amount.compareTo(new BigDecimal("9999999999.99"))<=0,"Số tiền nằm ngoài giới hạn thanh toán VNPAY.");
                Map<String,Object> attempt=Sql.one(c,"SELECT TOP 1 * FROM payment_attempts WHERE order_id=? AND status='pending' AND expires_at>DATEADD(second,30,SYSDATETIME()) ORDER BY created_at DESC",orderId);
                if(attempt==null) {
                    String ref=UUID.randomUUID().toString().replace("-","");
                    Sql.update(c,"INSERT INTO payment_attempts(reference,order_id,amount,expires_at) VALUES(?,?,?,DATEADD(minute,15,SYSDATETIME()))",ref,orderId,amount);
                    attempt=Sql.one(c,"SELECT * FROM payment_attempts WHERE reference=?",ref);
                }
                Map<String,String> fields=new TreeMap<>();
                fields.put("vnp_Version","2.1.0"); fields.put("vnp_Command","pay"); fields.put("vnp_TmnCode",VnpayConfig.get("VNPAY_TMN_CODE"));
                fields.put("vnp_Amount",amount.movePointRight(2).toBigIntegerExact().toString()); fields.put("vnp_CurrCode","VND");
                fields.put("vnp_TxnRef",Sql.string(attempt,"reference")); fields.put("vnp_OrderInfo","Thanh toan don banh "+Sql.string(o,"order_code").replaceAll("[^A-Za-z0-9]",""));
                fields.put("vnp_OrderType","other"); fields.put("vnp_Locale","vn"); fields.put("vnp_ReturnUrl",VnpayConfig.get("VNPAY_RETURN_URL"));
                fields.put("vnp_IpAddr","0:0:0:0:0:0:0:1".equals(ip)?"127.0.0.1":ip);
                DateTimeFormatter format=DateTimeFormatter.ofPattern("yyyyMMddHHmmss").withZone(ZoneId.of("Asia/Ho_Chi_Minh"));
                fields.put("vnp_CreateDate",format.format(((Timestamp)attempt.get("created_at")).toInstant()));
                fields.put("vnp_ExpireDate",format.format(((Timestamp)attempt.get("expires_at")).toInstant()));
                String url=VnpayConfig.SANDBOX_URL+"?"+VnpaySigner.canonical(fields)+"&vnp_SecureHash="+VnpaySigner.sign(fields,VnpayConfig.get("VNPAY_HASH_SECRET"));
                c.commit(); return url;
            } catch(Exception e) { c.rollback(); throw e; }
        }
    }
    public boolean verified(Map<String,String> fields) {
        return VnpayConfig.configured() && VnpayConfig.get("VNPAY_TMN_CODE").equals(fields.get("vnp_TmnCode"))
                && VnpaySigner.verify(fields,VnpayConfig.get("VNPAY_HASH_SECRET"));
    }
    /** Only called by the IPN endpoint. Browser return is deliberately read-only. */
    public String receive(Map<String,String> fields) throws Exception {
        if(!verified(fields)) return "97";
        String ref=fields.get("vnp_TxnRef");
        if(ref==null || !ref.matches("[a-zA-Z0-9]{1,64}")) return "01";
        String rawAmount=fields.get("vnp_Amount");
        if(rawAmount==null || !rawAmount.matches("[0-9]{1,14}")) return "04";
        boolean success="00".equals(fields.get("vnp_ResponseCode")) && "00".equals(fields.get("vnp_TransactionStatus"));
        String txn=fields.get("vnp_TransactionNo"),code=fields.get("vnp_ResponseCode");
        if(code==null || !code.matches("[0-9]{2}") || (success && (txn==null || !txn.matches("[0-9]{1,100}") || "0".equals(txn)))) return "99";
        try(Connection c=DBContext.getConnection()) {
            Map<String,Object> lookup=Sql.one(c,"SELECT order_id FROM payment_attempts WHERE reference=?",ref);
            if(lookup==null) return "01";
            int id=Sql.number(lookup,"order_id");
            c.setAutoCommit(false);
            try {
                Map<String,Object> o=Sql.one(c,"SELECT * FROM orders WITH(UPDLOCK,HOLDLOCK) WHERE order_id=?",id);
                Map<String,Object> p=Sql.one(c,"SELECT * FROM payments WITH(UPDLOCK,HOLDLOCK) WHERE order_id=?",id);
                Map<String,Object> a=Sql.one(c,"SELECT * FROM payment_attempts WITH(UPDLOCK,HOLDLOCK) WHERE reference=?",ref);
                if(p==null || !"VNPAY".equals(Sql.string(p,"payment_method"))) { c.rollback(); return "01"; }
                BigDecimal amount=new BigDecimal(rawAmount).movePointLeft(2);
                if(amount.compareTo((BigDecimal)a.get("amount"))!=0 || amount.compareTo((BigDecimal)p.get("amount"))!=0 || amount.compareTo((BigDecimal)o.get("total_amount"))!=0) { c.rollback(); return "04"; }
                if(!"pending".equals(Sql.string(a,"status"))) { c.rollback(); return "02"; }
                boolean paid=Arrays.asList("paid","refunded").contains(Sql.string(p,"payment_status"));
                Sql.update(c,"UPDATE payment_attempts SET status=?,response_code=?,transaction_no=?,duplicate_payment=?,completed_at=SYSDATETIME() WHERE reference=?",success?"succeeded":"failed",code,success?txn:null,success&&paid,ref);
                if(success && !paid) Sql.update(c,"UPDATE payments SET payment_status='paid',paid_at=SYSDATETIME(),transaction_code=? WHERE order_id=?",txn,id);
                if(!success && !paid && Sql.one(c,"SELECT reference FROM payment_attempts WHERE order_id=? AND status='pending'",id)==null)
                    Sql.update(c,"UPDATE payments SET payment_status='failed' WHERE order_id=?",id);
                OrderWorkflowService.event(c,id,null,"gateway",Sql.string(o,"order_status"),Sql.string(o,"order_status"),
                        "VNPAY " + ref + ": " + (success?"thành công":"thất bại") + (success&&paid?" · giao dịch thanh toán trùng, cần đối soát":""));
                c.commit(); return "00";
            } catch(Exception e) { c.rollback(); throw e; }
        }
    }
}
