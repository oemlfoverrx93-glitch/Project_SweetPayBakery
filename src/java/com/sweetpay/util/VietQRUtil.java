package com.sweetpay.util;

import java.nio.charset.StandardCharsets;

public class VietQRUtil {

    public static String generateEMVCoPayload(String binCode, String accountNumber, String amountStr, String transferContent) {
        StringBuilder payload = new StringBuilder();
        
        // 00 - Payload Format Indicator
        appendField(payload, "00", "01");
        
        // 01 - Point of Initiation Method (12 = dynamic)
        appendField(payload, "01", "12");
        
        // 38 - Merchant Account Information
        StringBuilder merchantInfo = new StringBuilder();
        appendField(merchantInfo, "00", "A000000727");
        
        StringBuilder beneficiaryOrg = new StringBuilder();
        appendField(beneficiaryOrg, "00", binCode);
        appendField(beneficiaryOrg, "01", accountNumber);
        
        appendField(merchantInfo, "01", beneficiaryOrg.toString());
        
        // Service code
        appendField(merchantInfo, "02", "QRIBFTTA");
        
        appendField(payload, "38", merchantInfo.toString());
        
        // 53 - Transaction Currency (VND)
        appendField(payload, "53", "704");
        
        // 54 - Transaction Amount
        if (amountStr != null && !amountStr.isEmpty()) {
            // Remove decimals if zero
            if (amountStr.endsWith(".00")) {
                amountStr = amountStr.substring(0, amountStr.length() - 3);
            }
            appendField(payload, "54", amountStr);
        }
        
        // 58 - Country Code
        appendField(payload, "58", "VN");
        
        // 62 - Additional Data Field Template
        if (transferContent != null && !transferContent.isEmpty()) {
            StringBuilder additionalData = new StringBuilder();
            appendField(additionalData, "08", transferContent);
            appendField(payload, "62", additionalData.toString());
        }
        
        // 63 - CRC
        payload.append("6304");
        String crc = calculateCRC16(payload.toString());
        payload.append(crc);
        
        return payload.toString();
    }

    private static void appendField(StringBuilder sb, String id, String value) {
        if (value != null && !value.isEmpty()) {
            sb.append(id);
            sb.append(String.format("%02d", value.length()));
            sb.append(value);
        }
    }

    private static String calculateCRC16(String data) {
        int crc = 0xFFFF; // Initial value
        int polynomial = 0x1021; // CRC-16-CCITT polynomial

        byte[] bytes = data.getBytes(StandardCharsets.UTF_8);
        for (byte b : bytes) {
            crc ^= (b & 0xFF) << 8;
            for (int i = 0; i < 8; i++) {
                if ((crc & 0x8000) != 0) {
                    crc = (crc << 1) ^ polynomial;
                } else {
                    crc <<= 1;
                }
            }
        }
        crc &= 0xFFFF;
        return String.format("%04X", crc);
    }
}
