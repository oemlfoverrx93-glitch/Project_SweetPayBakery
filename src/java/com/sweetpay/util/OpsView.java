package com.sweetpay.util;
import java.util.*;
import java.time.format.DateTimeFormatter;
import java.sql.Timestamp;
public final class OpsView {
    private OpsView() { }
    public static String e(Object value) { return HtmlUtil.escape(value==null?"":String.valueOf(value)); }
    public static String text(Map<String,Object> row,String key) { return row==null?"":e(row.get(key)); }
    public static int id(Map<String,Object> row,String key) { return row==null?0:Sql.number(row,key); }
    public static String money(Object value) { return String.format(Locale.forLanguageTag("vi-VN"),"%,.0f",value instanceof Number?value:0)+" ₫"; }
    public static String date(Object value) {
        if(value instanceof Timestamp) return ((Timestamp)value).toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        return value==null?"—":e(value);
    }
    public static String inputDate(Object value) {
        return value instanceof Timestamp?((Timestamp)value).toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")):"";
    }
    public static boolean active(Map<String,Object> row) { return row!=null && Boolean.TRUE.equals(row.get("status")); }
    public static String label(Object value) { return e(OrderPolicy.label(value==null?null:String.valueOf(value))); }
}
