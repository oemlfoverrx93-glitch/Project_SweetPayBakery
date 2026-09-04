package com.sweetpay.controller;

import com.sweetpay.dao.OperationsDAO;
import com.sweetpay.model.User;
import com.sweetpay.service.OrderWorkflowService;
import com.sweetpay.util.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns={"/admin/fulfillment","/staff/orders","/delivery/orders","/staff/inventory","/admin/reconciliation","/admin/reports","/cancel-order"})
public class OperationsServlet extends HttpServlet {
    private User actor(HttpServletRequest r) { return (User)r.getSession().getAttribute("user"); }
    @Override protected void doGet(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        String path=r.getServletPath();
        if("/cancel-order".equals(path)) { s.sendError(405); return; }
        User actor=actor(r); if(actor==null) { s.sendRedirect(r.getContextPath()+"/login"); return; }
        OperationsDAO dao=new OperationsDAO(); String view;
        try {
            r.setAttribute("basePath",path);
            if(path.endsWith("/inventory")) {
                r.setAttribute("pageTitle","Tồn kho bánh"); r.setAttribute("rows",dao.inventory()); view="inventory";
            } else if(path.endsWith("/reports")) {
                LocalDate from=LocalDate.now().withDayOfMonth(1),to=LocalDate.now();
                try {
                    if(r.getParameter("from")!=null) from=LocalDate.parse(r.getParameter("from"));
                    if(r.getParameter("to")!=null) to=LocalDate.parse(r.getParameter("to"));
                    if(to.isBefore(from) || from.getYear()<2000 || to.getYear()>2100) throw new IllegalArgumentException();
                } catch(RuntimeException e) { Forms.flash(r,"Khoảng ngày không hợp lệ. Đang hiển thị tháng hiện tại.",true); from=LocalDate.now().withDayOfMonth(1); to=LocalDate.now(); }
                r.setAttribute("from",from); r.setAttribute("to",to);
                r.setAttribute("report",dao.reports(Timestamp.valueOf(from.atStartOfDay()),Timestamp.valueOf(to.plusDays(1).atStartOfDay())));
                r.setAttribute("pageTitle","Báo cáo kinh doanh"); view="reports";
            } else {
                r.setAttribute("pageTitle",path.endsWith("reconciliation")?"Đối soát thanh toán":"delivery_staff".equals(actor.getRoleName())?"Đơn giao của tôi":"Điều hành đơn hàng");
                String status=Forms.text(r,"status",40,false),q=Forms.text(r,"q",100,false);
                r.setAttribute("rows",dao.orders(actor,status,q)); r.setAttribute("selectedStatus",status); r.setAttribute("query",q);
                if("admin".equals(actor.getRoleName())) r.setAttribute("staff",dao.staff());
                int id=Forms.integer(r,"id",0);
                if(id>0) {
                    Map<String,Object> detail=dao.detail(actor,id);
                    if(detail==null) { s.sendError(404); return; }
                    r.setAttribute("detail",detail); r.setAttribute("lines",dao.lines(id)); r.setAttribute("history",dao.history(id));
                }
                view="orders";
            }
            r.getRequestDispatcher("/WEB-INF/views/operations/"+view+".jsp").forward(r,s);
        } catch(IllegalArgumentException e) { s.sendError(400,e.getMessage()); }
        catch(Exception e) { throw new ServletException("Không thể tải dữ liệu điều hành.",e); }
    }
    @Override protected void doPost(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        User actor=actor(r);
        if(actor==null || !CsrfUtil.isValid(r)) { s.sendError(403); return; }
        String path=r.getServletPath(); int id=0;
        try {
            OrderWorkflowService service=new OrderWorkflowService();
            if(path.endsWith("/inventory")) service.adjustStock(actor,Forms.integer(r,"productId",0),Forms.integer(r,"quantity",-1),Forms.integer(r,"expected",-1),Forms.text(r,"note",500,true));
            else {
                id=Forms.integer(r,"orderId",0);
                String action="/cancel-order".equals(path)?"cancel_request":Forms.text(r,"action",40,true);
                service.act(actor,id,action,Forms.text(r,"target",40,false),Forms.integer(r,"driverId",0),Forms.text(r,"note",500,false),Forms.text(r,"reference",100,false),"yes".equals(r.getParameter("collected")));
            }
            Forms.flash(r,"Đã cập nhật thành công.",false);
        } catch(IllegalArgumentException e) { Forms.flash(r,e.getMessage(),true); }
        catch(Exception e) { getServletContext().log("Operation failed",e); Forms.flash(r,"Chưa thể lưu thay đổi. Tải lại trang và thử lại.",true); }
        String redirect="/cancel-order".equals(path)?"/order-detail":path;
        s.sendRedirect(r.getContextPath()+redirect+(id>0?"?id="+id:""));
    }
}
