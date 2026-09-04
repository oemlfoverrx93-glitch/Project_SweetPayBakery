package com.sweetpay.controller;

import com.sweetpay.dao.ManagementDAO;
import com.sweetpay.util.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns={"/admin/categories","/admin/vouchers","/admin/staff"})
public class ManagementServlet extends HttpServlet {
    private String kind(HttpServletRequest r) { return r.getServletPath().substring("/admin/".length()); }
    @Override protected void doGet(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        String kind=kind(r); r.setAttribute("kind",kind);
        r.setAttribute("pageTitle","categories".equals(kind)?"Danh mục bánh":"vouchers".equals(kind)?"Mã giảm giá":"Đội ngũ nhân viên");
        try {
            List<Map<String,Object>> rows=new ManagementDAO().list(kind); r.setAttribute("rows",rows);
            int id=Forms.integer(r,"edit",0);
            String key="categories".equals(kind)?"category_id":"vouchers".equals(kind)?"voucher_id":"user_id";
            for(Map<String,Object> row:rows) if(Sql.number(row,key)==id) r.setAttribute("editing",row);
            r.getRequestDispatcher("/WEB-INF/views/operations/management.jsp").forward(r,s);
        } catch(IllegalArgumentException e) { s.sendError(400); }
        catch(Exception e) { throw new ServletException("Không thể tải trang quản lý.",e); }
    }
    @Override protected void doPost(HttpServletRequest r,HttpServletResponse s) throws ServletException,IOException {
        try { new ManagementDAO().save(kind(r),r); Forms.flash(r,"Đã lưu thay đổi.",false); }
        catch(IllegalArgumentException e) { Forms.flash(r,e.getMessage(),true); }
        catch(Exception e) {
            getServletContext().log("Management update failed",e);
            Forms.flash(r,e instanceof SQLException?"Dữ liệu đang được sử dụng hoặc bị trùng. Vui lòng kiểm tra lại.":"Không thể lưu thay đổi. Vui lòng thử lại.",true);
        }
        s.sendRedirect(r.getContextPath()+r.getServletPath());
    }
}
