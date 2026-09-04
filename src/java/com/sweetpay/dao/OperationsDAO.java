package com.sweetpay.dao;

import com.sweetpay.model.User;
import com.sweetpay.util.*;
import java.sql.*;
import java.util.*;

public class OperationsDAO {
    public static final String ORDER_SQL = "SELECT o.*,p.payment_method,p.payment_status,p.amount,p.transaction_code,p.paid_at,"
            + "d.driver_id,u.full_name AS driver_name,d.assigned_at,d.picked_up_at,d.delivered_at,d.failure_reason,d.cod_collected_at,d.cod_remitted_at,d.cod_remit_reference,"
            + "cr.status AS cancel_status,cr.reason AS cancel_reason,cr.review_note AS cancel_review_note "
            + "FROM orders o LEFT JOIN payments p ON p.order_id=o.order_id "
            + "LEFT JOIN deliveries d ON d.order_id=o.order_id LEFT JOIN users u ON u.user_id=d.driver_id "
            + "LEFT JOIN cancellation_requests cr ON cr.order_id=o.order_id ";
    public List<Map<String,Object>> orders(User actor, String status, String q) throws Exception {
        String sql=ORDER_SQL+"WHERE 1=1 "; List<Object> args=new ArrayList<>();
        if ("delivery_staff".equals(actor.getRoleName())) { sql+="AND d.driver_id=? "; args.add(actor.getUserId()); }
        else if (!Arrays.asList("admin","store_staff").contains(actor.getRoleName())) { sql+="AND o.user_id=? "; args.add(actor.getUserId()); }
        if (status != null && !status.isEmpty()) {
            if ("cancel_requested".equals(status)) sql+="AND cr.status='requested' ";
            else { sql+="AND o.order_status=? "; args.add(status); }
        }
        if (q != null && !q.isEmpty()) { sql+="AND (o.order_code LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?) "; args.add("%"+q+"%"); args.add("%"+q+"%"); args.add("%"+q+"%"); }
        try(Connection c=DBContext.getConnection()) { return Sql.rows(c,sql+"ORDER BY o.order_date DESC,o.order_id DESC",args.toArray()); }
    }
    public Map<String,Object> detail(User actor, int id) throws Exception {
        try(Connection c=DBContext.getConnection()) {
            Map<String,Object> o=Sql.one(c,ORDER_SQL+"WHERE o.order_id=?",id);
            if(o==null) return null;
            String role=actor.getRoleName();
            if("delivery_staff".equals(role) && Sql.number(o,"driver_id")!=actor.getUserId()) return null;
            if(!Arrays.asList("admin","store_staff","delivery_staff").contains(role) && Sql.number(o,"user_id")!=actor.getUserId()) return null;
            return o;
        }
    }
    public List<Map<String,Object>> lines(int id) throws Exception {
        try(Connection c=DBContext.getConnection()) { return Sql.rows(c,"SELECT od.*,p.product_name,p.flavor,p.size FROM order_details od JOIN products p ON p.product_id=od.product_id WHERE order_id=?",id); }
    }
    public List<Map<String,Object>> history(int id) throws Exception {
        try(Connection c=DBContext.getConnection()) { return Sql.rows(c,"SELECT e.*,u.full_name AS actor_name FROM order_events e LEFT JOIN users u ON u.user_id=e.actor_id WHERE order_id=? ORDER BY event_id DESC",id); }
    }
    public List<Map<String,Object>> staff() throws Exception {
        try(Connection c=DBContext.getConnection()) { return Sql.rows(c,"SELECT u.user_id,u.full_name,u.email,u.phone,u.status,r.role_name FROM users u JOIN roles r ON r.role_id=u.role_id WHERE r.role_name IN ('store_staff','delivery_staff') ORDER BY u.full_name"); }
    }
    public List<Map<String,Object>> inventory() throws Exception {
        try(Connection c=DBContext.getConnection()) { return Sql.rows(c,"SELECT p.product_id,p.product_name,p.status,i.quantity_in_stock,i.min_stock_level,i.updated_at FROM products p JOIN inventory i ON i.product_id=p.product_id ORDER BY CASE WHEN i.quantity_in_stock<=i.min_stock_level THEN 0 ELSE 1 END,p.product_name"); }
    }
    public Map<String,List<Map<String,Object>>> reports(Timestamp from,Timestamp to) throws Exception {
        Map<String,List<Map<String,Object>>> report=new LinkedHashMap<>();
        try(Connection c=DBContext.getConnection()) {
            report.put("summary",Sql.rows(c,"SELECT COUNT(*) AS order_count,COALESCE(SUM(CASE WHEN o.order_status='completed' AND p.payment_status='paid' THEN o.total_amount ELSE 0 END),0) AS revenue, SUM(CASE WHEN o.order_status='completed' THEN 1 ELSE 0 END) AS completed_count,SUM(CASE WHEN o.order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_count FROM orders o LEFT JOIN payments p ON p.order_id=o.order_id WHERE o.order_date>=? AND o.order_date<?",from,to));
            report.put("daily",Sql.rows(c,"SELECT CAST(o.order_date AS DATE) AS day,COUNT(*) AS order_count,COALESCE(SUM(CASE WHEN o.order_status='completed' AND p.payment_status='paid' THEN o.total_amount ELSE 0 END),0) AS revenue FROM orders o LEFT JOIN payments p ON p.order_id=o.order_id WHERE o.order_date>=? AND o.order_date<? GROUP BY CAST(o.order_date AS DATE) ORDER BY day DESC",from,to));
            report.put("statuses",Sql.rows(c,"SELECT order_status,COUNT(*) AS order_count FROM orders WHERE order_date>=? AND order_date<? GROUP BY order_status",from,to));
            report.put("products",Sql.rows(c,"SELECT TOP 10 pr.product_name,SUM(od.quantity) AS quantity,SUM(od.quantity*od.unit_price) AS gross_sales FROM order_details od JOIN products pr ON pr.product_id=od.product_id JOIN orders o ON o.order_id=od.order_id JOIN payments p ON p.order_id=o.order_id WHERE o.order_status='completed' AND p.payment_status='paid' AND o.order_date>=? AND o.order_date<? GROUP BY pr.product_id,pr.product_name ORDER BY quantity DESC,pr.product_name",from,to));
            report.put("cod",Sql.rows(c,"SELECT u.full_name,COUNT(*) AS order_count,SUM(p.amount) AS amount FROM deliveries d JOIN payments p ON p.order_id=d.order_id JOIN users u ON u.user_id=d.driver_id WHERE d.cod_collected_at IS NOT NULL AND d.cod_remitted_at IS NULL GROUP BY u.user_id,u.full_name"));
            report.put("low_stock",Sql.rows(c,"SELECT p.product_name,i.quantity_in_stock,i.min_stock_level FROM inventory i JOIN products p ON p.product_id=i.product_id WHERE p.status=1 AND i.quantity_in_stock<=i.min_stock_level ORDER BY i.quantity_in_stock,p.product_name"));
            report.put("duplicates",Sql.rows(c,"SELECT pa.reference,pa.transaction_no,pa.amount,o.order_id,o.order_code FROM payment_attempts pa JOIN orders o ON o.order_id=pa.order_id WHERE pa.duplicate_payment=1 ORDER BY pa.created_at DESC"));
        }
        return report;
    }
}
