package com.sweetpay.controller;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/** Retain existing bookmarks while all mutations use the checked workflow. */
@WebServlet(name="AdminOrderServlet",urlPatterns={"/admin/orders","/admin/order/detail"})
public class AdminOrderServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest r,HttpServletResponse s) throws IOException {
        String id=r.getParameter("id");
        s.sendRedirect(r.getContextPath()+"/admin/fulfillment"+(id!=null && id.matches("[0-9]+")?"?id="+id:""));
    }
    @Override protected void doPost(HttpServletRequest r,HttpServletResponse s) throws IOException {
        s.sendError(405,"Sử dụng màn hình điều hành đơn hàng để cập nhật theo quy trình.");
    }
}
