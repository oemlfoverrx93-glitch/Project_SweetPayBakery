package com.sweetpay.util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class VnpaySigner {
    private VnpaySigner() { }
    public static String canonical(Map<String,String> values) {
        StringJoiner query=new StringJoiner("&");
        new TreeMap<>(values).forEach((key,value)-> {
            if(key.startsWith("vnp_") && !"vnp_SecureHash".equals(key) && !"vnp_SecureHashType".equals(key) && value!=null && !value.isEmpty())
                query.add(URLEncoder.encode(key,StandardCharsets.UTF_8)+"="+URLEncoder.encode(value,StandardCharsets.UTF_8));
        });
        return query.toString();
    }
    public static String sign(Map<String,String> values,String secret) {
        try {
            Mac mac=Mac.getInstance("HmacSHA512"); mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8),"HmacSHA512"));
            return HexFormat.of().formatHex(mac.doFinal(canonical(values).getBytes(StandardCharsets.UTF_8)));
        } catch(GeneralSecurityException e) { throw new IllegalStateException(e); }
    }
    public static boolean verify(Map<String,String> values,String secret) {
        String signature=values.get("vnp_SecureHash");
        if(secret==null || secret.isEmpty() || signature==null || !signature.matches("[a-fA-F0-9]{128}")) return false;
        return MessageDigest.isEqual(signature.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII),sign(values,secret).getBytes(StandardCharsets.US_ASCII));
    }
}
