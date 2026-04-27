package com.sweetpay.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GoogleAuthService {

    private static final String TOKEN_INFO_ENDPOINT = "https://oauth2.googleapis.com/tokeninfo?id_token=";

    public static class GoogleIdTokenPayload {

        private String sub;
        private String email;
        private String name;
        private String picture;
        private boolean emailVerified;
        private String audience;
        private String issuer;
        private long expEpochSeconds;

        public String getSub() {
            return sub;
        }

        public String getEmail() {
            return email;
        }

        public String getName() {
            return name;
        }

        public String getPicture() {
            return picture;
        }

        public boolean isEmailVerified() {
            return emailVerified;
        }

        public String getAudience() {
            return audience;
        }

        public String getIssuer() {
            return issuer;
        }

        public long getExpEpochSeconds() {
            return expEpochSeconds;
        }
    }

    public String getGoogleClientId() {
        String env = System.getenv("SWEETPAY_GOOGLE_CLIENT_ID");
        if (env != null && !env.trim().isEmpty()) {
            return env.trim();
        }

        String sys = System.getProperty("sweetpay.google.clientId");
        if (sys != null && !sys.trim().isEmpty()) {
            return sys.trim();
        }

        return "";
    }

    public GoogleIdTokenPayload verifyIdToken(String idToken) {
        if (idToken == null || idToken.trim().isEmpty()) {
            return null;
        }

        String response = callGoogleTokenInfo(idToken.trim());
        if (response == null || response.isEmpty()) {
            return null;
        }

        GoogleIdTokenPayload payload = parseTokenInfoJson(response);
        if (payload == null) {
            return null;
        }

        if (!isValidIssuer(payload.issuer)) {
            return null;
        }

        if (payload.expEpochSeconds <= Instant.now().getEpochSecond()) {
            return null;
        }

        String expectedAud = getGoogleClientId();
        if (!expectedAud.isEmpty() && !expectedAud.equals(payload.audience)) {
            return null;
        }

        return payload;
    }

    private String callGoogleTokenInfo(String idToken) {
        HttpURLConnection connection = null;
        try {
            String encoded = URLEncoder.encode(idToken, StandardCharsets.UTF_8.name());
            URL url = URI.create(TOKEN_INFO_ENDPOINT + encoded).toURL();
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(7000);
            connection.setReadTimeout(7000);

            int code = connection.getResponseCode();
            InputStream stream = code >= 200 && code < 300
                    ? connection.getInputStream()
                    : connection.getErrorStream();

            String body = readFully(stream);
            if (code >= 200 && code < 300) {
                return body;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
        return null;
    }

    private String readFully(InputStream stream) throws IOException {
        if (stream == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        }
        return builder.toString();
    }

    private GoogleIdTokenPayload parseTokenInfoJson(String json) {
        String sub = readString(json, "sub");
        String email = readString(json, "email");
        String aud = readString(json, "aud");
        String iss = readString(json, "iss");
        Long exp = readLong(json, "exp");

        if (sub == null || sub.isEmpty() || email == null || email.isEmpty() || exp == null) {
            return null;
        }

        GoogleIdTokenPayload payload = new GoogleIdTokenPayload();
        payload.sub = sub;
        payload.email = email;
        payload.name = readString(json, "name");
        payload.picture = readString(json, "picture");
        payload.audience = aud;
        payload.issuer = iss;
        payload.expEpochSeconds = exp;
        payload.emailVerified = readBoolean(json, "email_verified");
        return payload;
    }

    private boolean isValidIssuer(String issuer) {
        return "accounts.google.com".equalsIgnoreCase(issuer)
                || "https://accounts.google.com".equalsIgnoreCase(issuer);
    }

    private String readString(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        return matcher.find() ? matcher.group(1) : null;
    }

    private Long readLong(String json, String key) {
        Pattern quoted = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"(\\d+)\"");
        Matcher quotedMatcher = quoted.matcher(json);
        if (quotedMatcher.find()) {
            return parseLongSafe(quotedMatcher.group(1));
        }

        Pattern plain = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(\\d+)");
        Matcher plainMatcher = plain.matcher(json);
        if (plainMatcher.find()) {
            return parseLongSafe(plainMatcher.group(1));
        }
        return null;
    }

    private boolean readBoolean(String json, String key) {
        Pattern quoted = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"(true|false)\"");
        Matcher quotedMatcher = quoted.matcher(json);
        if (quotedMatcher.find()) {
            return Boolean.parseBoolean(quotedMatcher.group(1));
        }

        Pattern plain = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(true|false)");
        Matcher plainMatcher = plain.matcher(json);
        return plainMatcher.find() && Boolean.parseBoolean(plainMatcher.group(1));
    }

    private Long parseLongSafe(String value) {
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
