package com.sweetpay;

import com.sweetpay.dao.*;
import com.sweetpay.model.*;
import com.sweetpay.service.*;
import com.sweetpay.util.*;
import java.sql.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.*;

/** Run only against a disposable database named SweetPayBakeryOpsTest*. */
public class OperationsIntegrationTest {
    private static int checks;
    private static User admin,store,driver,otherDriver,customer,other;
    private static final OrderWorkflowService workflow=new OrderWorkflowService();
    private static final String SECRET="isolated-test-signing-key-not-a-merchant-credential";
    interface Checked { void run() throws Exception; }
    private static void check(boolean value,String name) { if(!value) throw new AssertionError(name); checks++; System.out.println("PASS "+name); }
    private static void denied(Checked action,String name) throws Exception { try { action.run(); } catch(IllegalArgumentException e) { check(true,name); return; } throw new AssertionError(name); }
    private static Map<String,Object> row(String sql,Object... args) throws Exception { try(Connection c=DBContext.getConnection()) { return Sql.one(c,sql,args); } }
    private static void update(String sql,Object... args) throws Exception { try(Connection c=DBContext.getConnection()) { Sql.update(c,sql,args); } }
    private static User user(String role,String email) throws Exception {
        update("INSERT INTO users(role_id,full_name,email,phone,password_hash,status) SELECT role_id,?,?,?, ?,1 FROM roles WHERE role_name=?",role+" test",email,"0901234567",PasswordUtil.hash("TestPassword123!"),role);
        return new UserDAO().findByEmail(email);
    }
    private static int place(String method,String receive,Integer voucher) throws Exception {
        Order o=new Order();o.setUserId(customer.getUserId());o.setRecipientName("Khách kiểm thử");o.setRecipientPhone("0901234567");o.setShippingAddress("Hà Nội");o.setReceiveMethod(receive);o.setVoucherId(voucher);
        OrderDetail d=new OrderDetail();d.setProductId(1);d.setQuantity(2);d.setUnitPrice(BigDecimal.ONE);
        Payment p=new Payment();p.setPaymentMethod(method);p.setPaymentStatus("COD".equals(method)?"unpaid":"pending");
        int id=new OrderDAO().placeOrder(o,new ArrayList<>(List.of(d)),p);check(id>0,"create "+method+" "+receive+" order");return id;
    }
    private static void act(User actor,int id,String action,String target,int driverId,String note,String ref,boolean collected) throws Exception { workflow.act(actor,id,action,target,driverId,note,ref,collected); }
    private static void step(User actor,int id,String target) throws Exception { act(actor,id,"transition",target,0,"","",false); }
    private static int stock() throws Exception { return Sql.number(row("SELECT quantity_in_stock FROM inventory WHERE product_id=1"),"quantity_in_stock"); }
    private static String status(int id) throws Exception { return Sql.string(row("SELECT payment_status FROM payments WHERE order_id=?",id),"payment_status"); }
    private static Map<String,String> callback(String ref,String code,String txn) throws Exception {
        Map<String,Object> a=row("SELECT amount FROM payment_attempts WHERE reference=?",ref);
        Map<String,String> values=new HashMap<>();values.put("vnp_TmnCode","TESTONLY");values.put("vnp_TxnRef",ref);values.put("vnp_Amount",((BigDecimal)a.get("amount")).movePointRight(2).toBigIntegerExact().toString());values.put("vnp_ResponseCode",code);values.put("vnp_TransactionStatus",code);values.put("vnp_TransactionNo",txn);sign(values);return values;
    }
    private static void sign(Map<String,String> values) { values.put("vnp_SecureHash",VnpaySigner.sign(values,SECRET)); }
    private static String reference(int id) throws Exception { return Sql.string(row("SELECT TOP 1 reference FROM payment_attempts WHERE order_id=? ORDER BY created_at DESC",id),"reference"); }
    public static void main(String[] args) throws Exception {
        String url=System.getProperty("sweetpay.db.url","");
        if(!url.contains("databaseName=SweetPayBakeryOpsTest")) throw new IllegalStateException("Use a disposable OpsTest database.");
        System.setProperty("VNPAY_TMN_CODE","TESTONLY"); System.setProperty("VNPAY_HASH_SECRET",SECRET);System.setProperty("VNPAY_RETURN_URL","http://localhost:18081/SweetBakery/payments/vnpay/return");
        try(Connection c=DBContext.getConnection()) { check(Sql.string(Sql.one(c,"SELECT DB_NAME() AS name"),"name").startsWith("SweetPayBakeryOpsTest"),"isolated test database"); }
        admin=new UserDAO().findByEmail("admin@sweetpay.com");customer=new UserDAO().findByEmail("vana@gmail.com");
        store=user("store_staff","store@ops.test");driver=user("delivery_staff","driver@ops.test");otherDriver=user("delivery_staff","driver2@ops.test");other=user("customer","other@ops.test");
        update("INSERT INTO inventory(product_id,quantity_in_stock) VALUES(1,1000),(2,1000)");
        check(new UserDAO().authenticateLocal("store@ops.test","TestPassword123!")!=null,"PBKDF2 login");check(new UserDAO().authenticateLocal("store@ops.test","wrong")==null,"wrong password rejected");
        check(new UserDAO().authenticateLocal("admin@sweetpay.com","admin123")!=null,"legacy login remains compatible");
        update("INSERT INTO vouchers(code,voucher_name,discount_type,discount_value,min_order_value,quantity,status) VALUES('TEST10',N'Test voucher','percent',10,0,5,1)");
        int voucher=Sql.number(row("SELECT voucher_id FROM vouchers WHERE code='TEST10'"),"voucher_id"),before=stock();
        int cancel=place("COD","delivery",voucher);
        check(((BigDecimal)row("SELECT total_amount FROM orders WHERE order_id=?",cancel).get("total_amount")).compareTo(new BigDecimal("576000"))==0,"prices and voucher recalculated from database");
        denied(()->act(other,cancel,"cancel_request","",0,"Hủy","",false),"customer cannot cancel another customer's order");
        act(customer,cancel,"cancel_request","",0,"Thay đổi kế hoạch","",false);
        denied(()->step(store,cancel,"confirmed"),"cancellation request blocks preparation");
        act(admin,cancel,"transition","cancelled",0,"Đồng ý hủy","",false);
        check(stock()==before,"cancel restores stock");check(Sql.number(row("SELECT quantity FROM vouchers WHERE voucher_id=?",voucher),"quantity")==5,"cancel restores voucher quota");
        denied(()->act(admin,cancel,"transition","cancelled",0,"Lặp lại","",false),"cancel cannot restore stock twice");check(stock()==before,"stock unchanged after duplicate cancel");
        int id=place("COD","delivery",null);
        denied(()->step(driver,id,"confirmed"),"driver cannot prepare orders");step(store,id,"confirmed");step(store,id,"preparing");step(store,id,"ready_for_delivery");
        denied(()->step(driver,id,"shipping"),"unassigned driver cannot take order");
        act(admin,id,"assign","",driver.getUserId(),"","",false);
        check(new OperationsDAO().detail(otherDriver,id)==null,"unassigned driver cannot read recipient detail");
        denied(()->step(otherDriver,id,"shipping"),"other driver cannot update order");denied(()->step(store,id,"shipping"),"store role cannot update delivery");
        step(driver,id,"shipping");denied(()->step(driver,id,"completed"),"COD completion requires collected-money acknowledgement");
        denied(()->step(driver,id,"delivery_failed"),"failed delivery requires reason");
        act(driver,id,"transition","delivery_failed",0,"Khách hẹn giao lại","",false);step(store,id,"ready_for_delivery");step(driver,id,"shipping");act(driver,id,"transition","completed",0,"","",true);
        check("paid".equals(status(id)),"successful COD delivery records payment");check(row("SELECT cod_collected_at FROM deliveries WHERE order_id=?",id).get("cod_collected_at")!=null,"COD collection recorded separately");
        denied(()->act(driver,id,"remit","",0,"","COD-TEST",false),"driver cannot approve own cash remittance");act(admin,id,"remit","",0,"Đã nhận đủ tiền","COD-TEST",false);
        denied(()->act(admin,id,"remit","",0,"","COD-TEST",false),"remittance cannot be recorded twice");
        int pickup=place("COD","pickup",null);step(store,pickup,"confirmed");step(store,pickup,"preparing");step(store,pickup,"ready_for_pickup");act(store,pickup,"transition","completed",0,"Khách đã nhận bánh","",true);
        check(row("SELECT reconciliation_id FROM payment_reconciliations WHERE order_id=? AND kind='pickup_cod'",pickup)!=null,"pickup COD has receipt");
        int bank=place("BANK_TRANSFER","delivery",null);act(customer,bank,"bank_notice","",0,"Đã chuyển","",false);
        check("pending".equals(status(bank)),"customer transfer report does not mark payment paid");denied(()->step(store,bank,"confirmed"),"unverified bank transfer cannot enter preparation");
        act(admin,bank,"bank_confirm","",0,"Đã đối chiếu","BANK-TEST",false);check("paid".equals(status(bank)),"admin bank reconciliation marks paid");
        act(customer,bank,"cancel_request","",0,"Xin hủy","",false);act(admin,bank,"transition","cancelled",0,"Chấp thuận","",false);act(admin,bank,"refund","",0,"Đã hoàn trên ngân hàng","REFUND-TEST",false);
        check("refunded".equals(status(bank)),"cancelled prepaid order can record refund evidence");
        denied(()->act(admin,bank,"refund","",0,"Lặp lại","REFUND-TEST",false),"refund cannot be recorded twice");
        int rejected=place("COD","delivery",null);act(customer,rejected,"cancel_request","",0,"Hủy","",false);act(admin,rejected,"reject_cancel","",0,"Đã trao đổi lại với khách","",false);step(store,rejected,"confirmed");
        check("confirmed".equals(row("SELECT order_status FROM orders WHERE order_id=?",rejected).get("order_status")),"rejected cancellation allows processing");
        int current=stock();workflow.adjustStock(store,1,current+10,current,"Bổ sung bánh");denied(()->workflow.adjustStock(store,1,current+20,current,"Biểu mẫu cũ"),"stale inventory update rejected");denied(()->workflow.adjustStock(customer,1,5,current+10,"Không có quyền"),"customer cannot edit stock");
        GatewayPaymentService gateway=new GatewayPaymentService();int online=place("VNPAY","delivery",null);
        String paymentUrl=gateway.start(online,customer.getUserId(),"127.0.0.1"),ref=reference(online);
        check(paymentUrl.startsWith(VnpayConfig.SANDBOX_URL+"?"),"gateway URL targets official sandbox");gateway.start(online,customer.getUserId(),"127.0.0.1");check(ref.equals(reference(online)),"repeated start reuses active attempt");
        denied(()->gateway.start(online,other.getUserId(),"127.0.0.1"),"other customer cannot start payment");
        Map<String,String> signed=callback(ref,"00","100001");signed.put("vnp_Amount","1");check("97".equals(gateway.receive(signed)),"tampered payment signature rejected");sign(signed);check("04".equals(gateway.receive(signed)),"signed wrong amount rejected");
        signed=callback(ref,"00","100001");signed.put("vnp_TmnCode","WRONG");sign(signed);check("97".equals(gateway.receive(signed)),"wrong merchant rejected");
        check("00".equals(gateway.receive(callback(ref,"00","100001"))),"valid IPN accepted");check("paid".equals(status(online)),"valid IPN marks order paid");check("02".equals(gateway.receive(callback(ref,"00","100001"))),"replayed IPN is idempotent");
        denied(()->act(admin,online,"bank_confirm","",0,"","X",false),"admin cannot use manual transfer confirmation for VNPAY");
        int retry=place("VNPAY","delivery",null);gateway.start(retry,customer.getUserId(),"127.0.0.1");String failedRef=reference(retry);check("00".equals(gateway.receive(callback(failedRef,"24","0"))),"failed IPN accepted");check("failed".equals(status(retry)),"failed payment recorded");gateway.start(retry,customer.getUserId(),"127.0.0.1");String retryRef=reference(retry);check(!retryRef.equals(failedRef),"retry creates new reference after terminal failure");gateway.receive(callback(retryRef,"00","100002"));gateway.receive(callback(failedRef,"24","0"));check("paid".equals(status(retry)),"old failed IPN cannot regress successful retry");
        int late=place("VNPAY","delivery",null);gateway.start(late,customer.getUserId(),"127.0.0.1");String lateRef=reference(late);act(customer,late,"cancel_request","",0,"Hủy","",false);act(admin,late,"transition","cancelled",0,"Chấp thuận","",false);gateway.receive(callback(lateRef,"00","100003"));check("paid".equals(status(late)) && "cancelled".equals(row("SELECT order_status FROM orders WHERE order_id=?",late).get("order_status")),"late payment keeps cancellation and creates refund due");
        int duplicate=place("VNPAY","delivery",null);gateway.start(duplicate,customer.getUserId(),"127.0.0.1");String old=reference(duplicate);update("UPDATE payment_attempts SET expires_at=DATEADD(minute,-1,SYSDATETIME()) WHERE reference=?",old);gateway.start(duplicate,customer.getUserId(),"127.0.0.1");String newer=reference(duplicate);gateway.receive(callback(newer,"00","100004"));gateway.receive(callback(old,"00","100005"));check(Boolean.TRUE.equals(row("SELECT duplicate_payment FROM payment_attempts WHERE reference=?",old).get("duplicate_payment")),"second successful attempt flagged for reconciliation");
        int concurrent=place("VNPAY","delivery",null);gateway.start(concurrent,customer.getUserId(),"127.0.0.1");String concurrentRef=reference(concurrent);Map<String,String> cb=callback(concurrentRef,"00","100006");
        ExecutorService pool=Executors.newFixedThreadPool(2);try {List<Future<String>> results=pool.invokeAll(List.of(()->gateway.receive(cb),()->gateway.receive(cb)));Set<String> codes=new HashSet<>();for(Future<String> result:results)codes.add(result.get());check(codes.equals(Set.of("00","02")),"concurrent IPN updates serialize exactly once");}finally{pool.shutdownNow();}
        Map<String,List<Map<String,Object>>> report=new OperationsDAO().reports(Timestamp.valueOf("2000-01-01 00:00:00"),Timestamp.valueOf("2100-01-01 00:00:00"));check(report.get("products").size()==1,"best sellers use completed paid orders");check(report.get("duplicates").size()==1,"duplicate-payment reconciliation report");
        check(new OperationsDAO().orders(otherDriver,"","").isEmpty(),"driver list only contains assigned orders");
        System.out.println("ALL "+checks+" CHECKS PASSED");
    }
}
