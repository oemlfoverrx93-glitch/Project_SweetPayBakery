package com.sweetpay.util;

import java.io.*;
import java.nio.file.*;
import java.util.Properties;

public final class VnpayConfig {
    public static final String SANDBOX_URL="https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private VnpayConfig() { }
    public static String get(String name) {
        String value=System.getProperty(name);
        if(value==null || value.isBlank()) value=System.getenv(name);
        if(value==null || value.isBlank()) {
            Path path=Paths.get(System.getProperty("catalina.base","."),"conf","sweetpay.properties.local");
            if(Files.isRegularFile(path)) {
                Properties p=new Properties();
                try(InputStream in=Files.newInputStream(path)) { p.load(in); value=p.getProperty(name); }
                catch(IOException e) { throw new IllegalStateException("Không đọc được cấu hình VNPAY.",e); }
            }
        }
        return value==null?"":value.trim();
    }
    public static boolean configured() {
        return !get("VNPAY_TMN_CODE").isEmpty() && !get("VNPAY_HASH_SECRET").isEmpty() && !get("VNPAY_RETURN_URL").isEmpty();
    }
}
