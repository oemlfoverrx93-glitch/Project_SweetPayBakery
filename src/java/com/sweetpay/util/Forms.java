package com.sweetpay.util;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import javax.servlet.http.*;

public final class Forms {
    private Forms() { }
    public static String text(HttpServletRequest r,String key,int max,boolean required) {
        String value=r.getParameter(key); value=value==null?"":value.trim();
        if(value.length()>max || required && value.isEmpty()) throw new IllegalArgumentException("Thông tin '"+key+"' bị thiếu hoặc quá dài.");
        return value;
    }
    public static int integer(HttpServletRequest r,String key,int fallback) {
        String raw=r.getParameter(key);
        if(raw==null || raw.isEmpty()) return fallback;
        try { return Integer.parseInt(raw); } catch(NumberFormatException e) { throw new IllegalArgumentException("Số không hợp lệ: "+key); }
    }
    public static BigDecimal money(HttpServletRequest r,String key,boolean optional) {
        String raw=text(r,key,20,!optional);
        if(raw.isEmpty()) return null;
        try {
            BigDecimal value=new BigDecimal(raw);
            if(value.scale()>2 || value.signum()<0 || value.compareTo(new BigDecimal("999999999999.99"))>0) throw new NumberFormatException();
            return value;
        } catch(NumberFormatException e) { throw new IllegalArgumentException("Số tiền không hợp lệ: "+key); }
    }
    public static Timestamp date(HttpServletRequest r,String key) {
        String raw=text(r,key,30,false);
        try { return raw.isEmpty()?null:Timestamp.valueOf(LocalDateTime.parse(raw)); }
        catch(RuntimeException e) { throw new IllegalArgumentException("Ngày giờ không hợp lệ."); }
    }
    public static void flash(HttpServletRequest r,String message,boolean error) {
        r.getSession().setAttribute("opsMessage",message); r.getSession().setAttribute("opsError",error);
    }
}
