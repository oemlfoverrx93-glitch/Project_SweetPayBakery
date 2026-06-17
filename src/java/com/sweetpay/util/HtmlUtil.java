package com.sweetpay.util;

public final class HtmlUtil {

    private HtmlUtil() {
    }

    public static String escape(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);
        StringBuilder escaped = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);
            switch (ch) {
                case '&':
                    escaped.append("&amp;");
                    break;
                case '<':
                    escaped.append("&lt;");
                    break;
                case '>':
                    escaped.append("&gt;");
                    break;
                case '"':
                    escaped.append("&quot;");
                    break;
                case '\'':
                    escaped.append("&#39;");
                    break;
                default:
                    escaped.append(ch);
                    break;
            }
        }
        return escaped.toString();
    }

    public static String escapeOr(Object value, String fallback) {
        if (value == null || String.valueOf(value).trim().isEmpty()) {
            return escape(fallback);
        }
        return escape(value);
    }
}
