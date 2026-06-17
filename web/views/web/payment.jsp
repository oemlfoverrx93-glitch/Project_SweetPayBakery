<%@page import="com.sweetpay.model.StoreBankAccount"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="com.sweetpay.util.CsrfUtil"%>
<%@page import="com.sweetpay.util.HtmlUtil"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán chuyển khoản - SweetPay Bakery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@500;600;700&family=Open+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/style.css?v=20260611-luxury1" rel="stylesheet">
</head>
<body class="sweet-payment-page">
<%
    String qrText = (String) request.getAttribute("qrText");
    String amount = (String) request.getAttribute("amount");
    String orderCode = (String) request.getAttribute("orderCode");
    Integer orderId = (Integer) request.getAttribute("orderId");
    StoreBankAccount account = (StoreBankAccount) request.getAttribute("account");
    String csrfToken = CsrfUtil.getToken(session);

    if (qrText == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    String bankName      = (account != null) ? account.getBankName()      : "Ngân hàng Quân đội (MB Bank)";
    String accountNumber = (account != null) ? account.getAccountNumber() : "240220060903";
    String accountHolder = (account != null) ? account.getAccountHolder() : "Nguyễn Thị Tuyết Mai";
    String encodedQR     = URLEncoder.encode(qrText, "UTF-8");

    String formattedAmount = amount;
    try {
        long amountLong = Long.parseLong(amount);
        formattedAmount = String.format("%,d", amountLong).replace(",", ".");
    } catch (NumberFormatException nfe) { }
%>

<main class="container sweet-shell">
    <div class="row justify-content-center">
        <div class="col-sm-11 col-md-8 col-lg-6">
            <div class="text-center mb-4">
                <span class="sweet-eyebrow justify-content-center">Thanh toán</span>
                <h1 class="sweet-page-title">Chuyển khoản đơn bánh</h1>
                <p class="sweet-page-subtitle mx-auto">Quét mã QR hoặc chuyển khoản thủ công theo đúng số tiền và nội dung bên dưới.</p>
            </div>

            <div class="checkout-steps">
                <div class="checkout-step">1. Giỏ hàng</div>
                <div class="checkout-step">2. Thông tin</div>
                <div class="checkout-step is-active">3. Thanh toán</div>
                <div class="checkout-step">4. Hoàn tất</div>
            </div>

            <div class="card payment-card">
                <div class="card-body p-4">
                    <div class="text-center mb-4">
                        <div class="qr-box">
                            <img src="<%=request.getContextPath()%>/generateQR?text=<%=encodedQR%>"
                                 alt="Mã QR chuyển khoản"
                                 width="240" height="240" />
                        </div>
                        <p class="text-muted mt-2 mb-0 small">Mở app ngân hàng và quét mã QR</p>
                    </div>

                    <hr>

                    <p class="sweet-eyebrow">Thông tin chuyển khoản</p>
                    <table class="info-table w-100">
                        <tr>
                            <td>Ngân hàng</td>
                            <td><%=HtmlUtil.escape(bankName)%></td>
                        </tr>
                        <tr>
                            <td>Chủ tài khoản</td>
                            <td><%=HtmlUtil.escape(accountHolder)%></td>
                        </tr>
                        <tr>
                            <td>Số tài khoản</td>
                            <td>
                                <span id="stk"><%=HtmlUtil.escape(accountNumber)%></span>
                                <button class="copy-btn" onclick="copyText('stk', this)" type="button">Sao chép</button>
                            </td>
                        </tr>
                        <tr>
                            <td>Số tiền</td>
                            <td class="amount-text"><%=formattedAmount%> VND</td>
                        </tr>
                        <tr>
                            <td>Nội dung CK</td>
                            <td>
                                <span id="content"><%=HtmlUtil.escape(orderCode)%></span>
                                <button class="copy-btn" onclick="copyText('content', this)" type="button">Sao chép</button>
                            </td>
                        </tr>
                    </table>

                    <div class="alert alert-warning mt-4 mb-4">
                        Vui lòng chuyển đúng số tiền và đúng nội dung để đơn hàng được xử lý nhanh nhất.
                    </div>

                    <div class="d-grid gap-2">
                        <form action="<%=request.getContextPath()%>/payment" method="post" class="d-grid">
                            <input type="hidden" name="csrfToken" value="<%=csrfToken%>">
                            <input type="hidden" name="orderId" value="<%=orderId%>">
                            <button type="submit" class="btn btn-confirm">Xác nhận đã chuyển khoản</button>
                        </form>
                        <a href="<%=request.getContextPath()%>/home"
                           class="btn btn-outline-secondary text-decoration-none text-center">
                            Quay về trang chủ
                        </a>
                    </div>
                </div>
            </div>

            <p class="text-center text-muted mt-3 small">
                Mã đơn hàng: <strong><%=HtmlUtil.escape(orderCode)%></strong>. Admin sẽ xác nhận sau khi kiểm tra giao dịch.
            </p>
        </div>
    </div>
</main>

<script>
function copyText(elementId, btn) {
    var text = document.getElementById(elementId).innerText;
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(function() {
            btn.innerText = 'Đã sao chép';
            setTimeout(function() { btn.innerText = 'Sao chép'; }, 1500);
        });
    } else {
        var el = document.createElement('textarea');
        el.value = text;
        el.style.position = 'absolute';
        el.style.left = '-9999px';
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
        btn.innerText = 'Đã sao chép';
        setTimeout(function() { btn.innerText = 'Sao chép'; }, 1500);
    }
}
</script>
</body>
</html>
