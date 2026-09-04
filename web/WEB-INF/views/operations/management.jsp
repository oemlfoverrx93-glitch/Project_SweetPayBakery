<%@page pageEncoding="UTF-8"%>
<%@ include file="_header.jspf" %>
<% String kind=(String)request.getAttribute("kind"); List<Map<String,Object>> rows=(List<Map<String,Object>>)request.getAttribute("rows");
Map<String,Object> editing=(Map<String,Object>)request.getAttribute("editing"); boolean category="categories".equals(kind),voucher="vouchers".equals(kind);
String key=category?"category_id":voucher?"voucher_id":"user_id"; String path=opsContext+"/admin/"+kind; %>
<div class="ops-card ops-management-editor"><div class="ops-card-header"><h2><%=editing==null?"Thêm mới":"Chỉnh sửa"%></h2><% if(editing!=null) { %><a href="<%=path%>" class="ops-link">Hủy chỉnh sửa</a><% } %></div>
<form action="<%=path%>" method="post" class="ops-form-grid"><%@ include file="_csrf.jspf" %><input type="hidden" name="action" value="save"><input type="hidden" name="id" value="<%=OpsView.id(editing,key)%>">
<div><label for="name"><%=category?"Tên danh mục":voucher?"Tên chương trình":"Họ và tên"%></label><input id="name" name="name" required maxlength="100" value="<%=OpsView.text(editing,category?"category_name":voucher?"voucher_name":"full_name")%>"></div>
<% if(category) { %>
<div><label for="slug">Đường dẫn</label><input id="slug" name="slug" required maxlength="100" pattern="[a-z0-9]+(-[a-z0-9]+)*" placeholder="banh-sinh-nhat" value="<%=OpsView.text(editing,"slug")%>"></div>
<div class="wide"><label for="description">Mô tả</label><textarea id="description" name="description" maxlength="255" rows="2"><%=OpsView.text(editing,"description")%></textarea></div>
<% } else if(voucher) { %>
<div><label for="code">Mã giảm giá</label><input id="code" name="code" required maxlength="50" placeholder="SWEET10" value="<%=OpsView.text(editing,"code")%>"></div>
<div><label for="discountType">Hình thức giảm</label><select id="discountType" name="discountType"><option value="percent">Phần trăm (%)</option><option value="fixed" <%=editing!=null&&"fixed".equals(editing.get("discount_type"))?"selected":""%>>Số tiền (VNĐ)</option></select></div>
<div><label for="discountValue">Giá trị giảm</label><input id="discountValue" name="discountValue" type="number" min="0.01" step="0.01" required value="<%=OpsView.text(editing,"discount_value")%>"></div>
<div><label for="minimum">Giá trị đơn tối thiểu (VNĐ)</label><input id="minimum" name="minimum" type="number" min="0" step="0.01" required value="<%=editing==null?"0":OpsView.text(editing,"min_order_value")%>"></div>
<div><label for="maximum">Giảm tối đa (VNĐ, tùy chọn)</label><input id="maximum" name="maximum" type="number" min="0.01" step="0.01" value="<%=OpsView.text(editing,"max_discount")%>"></div>
<div><label for="quantity">Số lượt còn lại</label><input id="quantity" name="quantity" type="number" min="0" max="1000000" required value="<%=editing==null?"100":OpsView.text(editing,"quantity")%>"><input type="hidden" name="expectedQuantity" value="<%=OpsView.text(editing,"quantity")%>"></div>
<div><label for="startDate">Bắt đầu (giờ Việt Nam)</label><input id="startDate" name="startDate" type="datetime-local" value="<%=editing==null?"":OpsView.inputDate(editing.get("start_date"))%>"></div>
<div><label for="endDate">Kết thúc (giờ Việt Nam)</label><input id="endDate" name="endDate" type="datetime-local" value="<%=editing==null?"":OpsView.inputDate(editing.get("end_date"))%>"></div>
<% } else { %>
<div><label for="email">Email đăng nhập</label><input id="email" name="email" type="email" required maxlength="100" value="<%=OpsView.text(editing,"email")%>"></div>
<div><label for="phone">Số điện thoại</label><input id="phone" name="phone" type="tel" required maxlength="20" value="<%=OpsView.text(editing,"phone")%>"></div>
<div><label for="role">Vai trò</label><select id="role" name="role"><option value="store_staff">Nhân viên cửa hàng</option><option value="delivery_staff" <%=editing!=null&&"delivery_staff".equals(editing.get("role_name"))?"selected":""%>>Nhân viên giao hàng</option></select></div>
<div class="wide"><label for="password"><%=editing==null?"Mật khẩu ban đầu":"Mật khẩu mới (để trống để giữ nguyên)"%></label><input id="password" name="password" type="password" minlength="8" maxlength="128" autocomplete="new-password" <%=editing==null?"required":""%>></div>
<% } %>
<div class="wide ops-actions"><button type="submit"><%=editing==null?"Tạo mới":"Lưu thay đổi"%></button><span class="ops-muted"><%=category?"Ẩn danh mục sẽ ẩn các bánh thuộc danh mục khỏi cửa hàng.":voucher?"Mã mới được kích hoạt ngay trong thời gian áp dụng.":"Nhân viên đăng nhập tại trang đăng nhập của cửa hàng."%></span></div></form></div>
<section class="ops-card"><div class="ops-card-header"><h2>Danh sách <%=category?"danh mục":voucher?"mã giảm giá":"nhân viên"%></h2><span class="ops-chip"><%=rows.size()%> mục</span></div>
<div class="ops-table-wrap"><table><thead><tr><th><%=category?"Danh mục":voucher?"Chương trình":"Nhân viên"%></th><th>Thông tin</th><th>Trạng thái</th><th>Thao tác</th></tr></thead><tbody>
<% for(Map<String,Object> row:rows) { int id=OpsView.id(row,key); %>
<tr><td><strong><%=OpsView.text(row,category?"category_name":voucher?"voucher_name":"full_name")%></strong><small>#<%=id%></small></td>
<td><% if(category) { %><%=OpsView.text(row,"slug")%><small><%=OpsView.text(row,"product_count")%> sản phẩm</small>
<% } else if(voucher) { %><strong><%=OpsView.text(row,"code")%> · <%=OpsView.text(row,"discount_value")%><%="percent".equals(row.get("discount_type"))?"%":" ₫"%></strong><small>Còn <%=OpsView.text(row,"quantity")%> lượt · <%=OpsView.text(row,"used_count")%> đơn đang dùng</small><small><%=OpsView.date(row.get("start_date"))%> → <%=OpsView.date(row.get("end_date"))%></small>
<% } else { %><%=OpsView.text(row,"email")%><small><%=OpsView.label(row.get("role_name"))%> · <%=OpsView.text(row,"phone")%></small><% } %></td>
<td><span class="ops-badge <%=OpsView.active(row)?"paid":""%>"><%=OpsView.active(row)?"Đang hoạt động":"Đã tắt"%></span></td>
<td><div class="ops-actions"><a class="ops-btn secondary" href="<%=path%>?edit=<%=id%>">Sửa</a><form action="<%=path%>" method="post"><%@ include file="_csrf.jspf" %><input type="hidden" name="id" value="<%=id%>"><input type="hidden" name="action" value="toggle"><button class="secondary"><%=OpsView.active(row)?"Tắt":"Bật"%></button></form>
<% if(category||voucher) { %><form action="<%=path%>" method="post" data-confirm="Xóa mục này? Chỉ xóa được khi chưa có dữ liệu liên kết."><%@ include file="_csrf.jspf" %><input type="hidden" name="id" value="<%=id%>"><input type="hidden" name="action" value="delete"><button class="secondary">Xóa</button></form><% } %></div></td></tr>
<% } if(rows.isEmpty()) { %><tr><td colspan="4" class="ops-empty">Chưa có dữ liệu. Sử dụng biểu mẫu phía trên để tạo mới.</td></tr><% } %>
</tbody></table></div></section>
<%@ include file="_footer.jspf" %>
