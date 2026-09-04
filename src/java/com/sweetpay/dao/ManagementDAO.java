package com.sweetpay.dao;

import com.sweetpay.util.*;
import java.sql.*;
import java.math.BigDecimal;
import java.util.*;
import javax.servlet.http.HttpServletRequest;
import static com.sweetpay.service.OrderWorkflowService.require;

public class ManagementDAO {
    public List<Map<String,Object>> list(String kind) throws Exception {
        try(Connection c=DBContext.getConnection()) {
            if("categories".equals(kind)) return Sql.rows(c,"SELECT c.*,(SELECT COUNT(*) FROM products p WHERE p.category_id=c.category_id) AS product_count FROM categories c ORDER BY category_name");
            if("vouchers".equals(kind)) return Sql.rows(c,"SELECT v.*,(SELECT COUNT(*) FROM orders o WHERE o.voucher_id=v.voucher_id AND o.order_status<>'cancelled') AS used_count FROM vouchers v ORDER BY voucher_id DESC");
            return new OperationsDAO().staff();
        }
    }
    public void save(String kind,HttpServletRequest r) throws Exception {
        String action=Forms.text(r,"action",20,true); int id=Forms.integer(r,"id",0);
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                if("categories".equals(kind)) category(c,r,action,id);
                else if("vouchers".equals(kind)) voucher(c,r,action,id);
                else staff(c,r,action,id);
                c.commit();
            } catch(Exception e) { c.rollback(); throw e; }
        }
    }
    private void category(Connection c,HttpServletRequest r,String action,int id) throws Exception {
        if("delete".equals(action)) {
            require(Sql.update(c,"DELETE FROM categories WHERE category_id=? AND NOT EXISTS(SELECT 1 FROM products WHERE category_id=?)",id,id)>0,"Danh mục đang có sản phẩm. Hãy ẩn danh mục thay vì xóa."); return;
        }
        if("toggle".equals(action)) { require(Sql.update(c,"UPDATE categories SET status=CASE WHEN status=1 THEN 0 ELSE 1 END WHERE category_id=?",id)>0,"Không tìm thấy danh mục."); return; }
        require("save".equals(action),"Thao tác không hợp lệ.");
        String name=Forms.text(r,"name",100,true),slug=Forms.text(r,"slug",100,true),description=Forms.text(r,"description",255,false);
        require(slug.matches("[a-z0-9]+(?:-[a-z0-9]+)*"),"Đường dẫn chỉ gồm chữ thường không dấu, số và dấu gạch ngang.");
        require(Sql.one(c,"SELECT category_id FROM categories WHERE slug=? AND category_id<>?",slug,id)==null,"Đường dẫn danh mục đã tồn tại.");
        if(id==0) Sql.update(c,"INSERT INTO categories(category_name,slug,description,status) VALUES(?,?,?,1)",name,slug,description);
        else require(Sql.update(c,"UPDATE categories SET category_name=?,slug=?,description=? WHERE category_id=?",name,slug,description,id)>0,"Không tìm thấy danh mục.");
    }
    private void voucher(Connection c,HttpServletRequest r,String action,int id) throws Exception {
        if("delete".equals(action)) {
            require(Sql.update(c,"DELETE FROM vouchers WHERE voucher_id=? AND NOT EXISTS(SELECT 1 FROM orders WHERE voucher_id=?)",id,id)>0,"Mã đã gắn với đơn hàng. Hãy tắt mã thay vì xóa."); return;
        }
        if("toggle".equals(action)) { require(Sql.update(c,"UPDATE vouchers SET status=CASE WHEN status=1 THEN 0 ELSE 1 END WHERE voucher_id=?",id)>0,"Không tìm thấy mã."); return; }
        require("save".equals(action),"Thao tác không hợp lệ.");
        String code=Forms.text(r,"code",50,true).toUpperCase(Locale.ROOT),name=Forms.text(r,"name",100,true),type=Forms.text(r,"discountType",20,true);
        require(code.matches("[A-Z0-9_-]+"),"Mã giảm giá chỉ gồm chữ không dấu, số, gạch ngang hoặc gạch dưới.");
        BigDecimal value=Forms.money(r,"discountValue",false),min=Forms.money(r,"minimum",false),max=Forms.money(r,"maximum",true);
        int quantity=Forms.integer(r,"quantity",-1);
        require(Arrays.asList("fixed","percent").contains(type) && value.signum()>0 && (!"percent".equals(type) || value.compareTo(new BigDecimal("100"))<=0),"Giá trị giảm phải lớn hơn 0; phần trăm tối đa là 100.");
        require(quantity>=0 && quantity<=1000000 && (max==null || max.signum()>0),"Lượt còn lại hoặc mức giảm tối đa không hợp lệ.");
        Timestamp start=Forms.date(r,"startDate"),end=Forms.date(r,"endDate");
        require(start==null || end==null || !end.before(start),"Ngày kết thúc phải sau ngày bắt đầu.");
        require(Sql.one(c,"SELECT voucher_id FROM vouchers WHERE code=? AND voucher_id<>?",code,id)==null,"Mã giảm giá đã tồn tại.");
        if(id==0) Sql.update(c,"INSERT INTO vouchers(code,voucher_name,discount_type,discount_value,min_order_value,max_discount,quantity,start_date,end_date,status) VALUES(?,?,?,?,?,?,?,?,?,1)",code,name,type,value,min,max,quantity,start,end);
        else {
            int expected=Forms.integer(r,"expectedQuantity",-1);
            require(Sql.update(c,"UPDATE vouchers SET code=?,voucher_name=?,discount_type=?,discount_value=?,min_order_value=?,max_discount=?,quantity=?,start_date=?,end_date=? WHERE voucher_id=? AND quantity=?",code,name,type,value,min,max,quantity,start,end,id,expected)>0,
                    "Lượt sử dụng vừa thay đổi hoặc mã không tồn tại. Tải lại trang trước khi lưu.");
        }
    }
    private void staff(Connection c,HttpServletRequest r,String action,int id) throws Exception {
        if("toggle".equals(action)) {
            require(Sql.update(c,"UPDATE users SET status=CASE WHEN status=1 THEN 0 ELSE 1 END WHERE user_id=? AND role_id IN(SELECT role_id FROM roles WHERE role_name IN('store_staff','delivery_staff'))",id)>0,"Không tìm thấy tài khoản nhân viên."); return;
        }
        require("save".equals(action),"Thao tác không hợp lệ.");
        String name=Forms.text(r,"name",100,true),email=Forms.text(r,"email",100,true),phone=Forms.text(r,"phone",20,true),role=Forms.text(r,"role",30,true),password=Forms.text(r,"password",128,false);
        require(email.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+") && phone.matches("[0-9+][0-9 ]{8,18}"),"Email hoặc số điện thoại không hợp lệ.");
        require(Arrays.asList("store_staff","delivery_staff").contains(role),"Chọn vai trò nhân viên hợp lệ.");
        require(id!=0 || password.length()>=8,"Mật khẩu tài khoản mới phải có ít nhất 8 ký tự.");
        require(password.isEmpty() || password.length()>=8,"Mật khẩu phải có ít nhất 8 ký tự.");
        Map<String,Object> rr=Sql.one(c,"SELECT role_id FROM roles WHERE role_name=?",role); require(rr!=null,"Chưa chạy migration 09.");
        require(Sql.one(c,"SELECT user_id FROM users WHERE email=? AND user_id<>?",email,id)==null,"Email đã được sử dụng.");
        if(id==0) Sql.update(c,"INSERT INTO users(role_id,full_name,email,phone,password_hash,status) VALUES(?,?,?,?,?,1)",rr.get("role_id"),name,email,phone,PasswordUtil.hash(password));
        else {
            Map<String,Object> old=Sql.one(c,"SELECT u.user_id,r.role_name FROM users u WITH(UPDLOCK,HOLDLOCK) JOIN roles r ON r.role_id=u.role_id WHERE u.user_id=?",id);
            require(old!=null && Arrays.asList("store_staff","delivery_staff").contains(Sql.string(old,"role_name")),"Không tìm thấy nhân viên.");
            if(!role.equals(Sql.string(old,"role_name"))) require(Sql.one(c,"SELECT TOP 1 d.order_id FROM deliveries d JOIN orders o ON o.order_id=d.order_id WHERE d.driver_id=? AND (o.order_status NOT IN('completed','cancelled') OR (d.cod_collected_at IS NOT NULL AND d.cod_remitted_at IS NULL))",id)==null,
                    "Nhân viên còn đơn đang giao hoặc tiền COD chưa bàn giao. Hoàn tất xử lý trước khi đổi vai trò.");
            Sql.update(c,"UPDATE users SET role_id=?,full_name=?,email=?,phone=? WHERE user_id=?",rr.get("role_id"),name,email,phone,id);
            if(!password.isEmpty()) Sql.update(c,"UPDATE users SET password_hash=? WHERE user_id=?",PasswordUtil.hash(password),id);
        }
    }
}
