package com.sweetpay.controller;

import com.sweetpay.service.GatewayPaymentService;
import com.sweetpay.util.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns={"/payments/start","/payments/vnpay/ipn","/payments/vnpay/return"})
public class GatewayPaymentServlet extends HttpServlet {
    @Override protected void doPost(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        if(!"/payments/start".equals(r.getServletPath())) { s.sendError(405); return; }
        Integer user=AuthSessionUtil.getUserId(r.getSession(false));
        if(user==null || !CsrfUtil.isValid(r)) { s.sendError(403); return; }
        int id=0;
        try {
            id=Forms.integer(r,"orderId",0);
            s.sendRedirect(new GatewayPaymentService().start(id,user,r.getRemoteAddr()));
        } catch(IllegalArgumentException e) { Forms.flash(r,e.getMessage(),true); s.sendRedirect(r.getContextPath()+"/order-detail?id="+id); }
        catch(Exception e) { getServletContext().log("VNPAY start failed",e); Forms.flash(r,"Chưa thể kết nối thanh toán. Bạn có thể thử lại từ chi tiết đơn.",true); s.sendRedirect(r.getContextPath()+"/order-detail?id="+id); }
    }
    private Map<String,String> fields(HttpServletRequest r) {
        Map<String,String> result=new TreeMap<>();
        r.getParameterMap().forEach((key,values)-> {
            if(key.startsWith("vnp_")) {
                if(values.length!=1 || values[0].length()>1000) throw new IllegalArgumentException();
                result.put(key,values[0]);
            }
        }); return result;
    }
    @Override protected void doGet(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        String path=r.getServletPath();
        s.setHeader("Cache-Control","no-store");
        if("/payments/start".equals(path)) { s.sendError(405); return; }
        GatewayPaymentService service=new GatewayPaymentService();
        if(path.endsWith("/ipn")) {
            String code;
            try { code=service.receive(fields(r)); }
            catch(IllegalArgumentException e) { code="97"; }
            catch(Exception e) { getServletContext().log("VNPAY IPN failed",e); code="99"; }
            s.setContentType("application/json;charset=UTF-8");
            s.getWriter().write("{\"RspCode\":\""+code+"\",\"Message\":\""+("00".equals(code)?"Confirm Success":"02".equals(code)?"Already confirmed":"Rejected")+"\"}");
            return;
        }
        try {
            Map<String,String> values=fields(r);
            if(!service.verified(values)) { s.sendError(400,"Kết quả thanh toán không hợp lệ."); return; }
            try(Connection c=DBContext.getConnection()) {
                Map<String,Object> row=Sql.one(c,"SELECT o.order_id,o.user_id FROM payment_attempts a JOIN orders o ON o.order_id=a.order_id WHERE a.reference=?",values.get("vnp_TxnRef"));
                if(row==null) { s.sendError(404); return; }
                Integer user=AuthSessionUtil.getUserId(r.getSession(false));
                int id=Sql.number(row,"order_id");
                if(user==null) { s.sendRedirect(r.getContextPath()+"/login?redirect="+java.net.URLEncoder.encode("/order-detail?id="+id,java.nio.charset.StandardCharsets.UTF_8)); return; }
                if(user!=Sql.number(row,"user_id")) { s.sendError(403); return; }
                Forms.flash(r,"Đã trở về từ VNPAY. Trạng thái thanh toán chỉ được xác nhận khi cửa hàng nhận kết quả từ cổng thanh toán; tải lại chi tiết đơn nếu đang chờ.",false);
                s.sendRedirect(r.getContextPath()+"/order-detail?id="+id);
            }
        } catch(IllegalArgumentException e) { s.sendError(400); }
        catch(Exception e) { throw new ServletException(e); }
    }
}
