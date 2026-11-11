"use strict";

const products = [
  {id:"dau",sku:"BK-DAU",name:"Bánh kem dâu tươi",category:"Bánh sinh nhật",price:320000,capacity:16,sizes:["16 cm","20 cm"],flavors:["Dâu tươi","Vani"],ingredients:"Bột mì, trứng, kem sữa và dâu tươi.",active:true},
  {id:"tiramisu",sku:"TRM-CA",name:"Tiramisu cacao",category:"Tiramisu",price:185000,capacity:24,sizes:["1 phần"],flavors:["Cacao"],ingredients:"Mascarpone, cacao, trứng và bánh quy.",active:true},
  {id:"chocolate",sku:"BK-CHO",name:"Bánh chocolate mâm xôi",category:"Bánh sinh nhật",price:345000,capacity:12,sizes:["16 cm","20 cm"],flavors:["Chocolate"],ingredients:"Chocolate đen, mâm xôi, trứng và bột mì.",active:true},
  {id:"croissant",sku:"CRO-BO",name:"Croissant bơ",category:"Croissant",price:48000,capacity:30,sizes:["1 phần"],flavors:["Bơ"],ingredients:"Bột mì, bơ và men.",active:true}
];
const sampleProfile={name:"Nguyễn Minh Anh",email:"minhanh@example.com",phone:"0900000123",birthday:"2004-08-12",address:"12 Nguyễn Trãi, TP. Hồ Chí Minh"};
const orderSample=(id,item,total,status,date="2026-05-17",delivery="Giao tận nơi")=>({id,item,total,status,date,delivery,slot:"14:00 – 16:00",...sampleProfile});
const sampleOrders=[
  {...orderSample("BN-260516-018","dau",356200,"Đang giao"),tracking:"AHM-018"},
  orderSample("BN-260510-006","tiramisu",185000,"Đã giao","2026-05-10","Nhận tại cửa hàng"),
  orderSample("BN-260516-019","dau",320000,"Chờ xác nhận","2026-05-18","Nhận tại cửa hàng"),
  {...orderSample("BN-260516-020","chocolate",370000,"Đã chuẩn bị","2026-05-18"),name:"Trần Thu Hà"}
];
const sampleVouchers=[
  {code:"BANH10",type:"Phần trăm",value:10,min:300000,cap:80000,start:"2026-05-01",end:"2026-05-31",used:28,limit:100,each:1,category:"Tất cả",active:true},
  {code:"GIAO25",type:"Miễn phí giao",value:25000,min:300000,cap:25000,start:"2026-05-20",end:"2026-05-25",used:0,limit:50,each:1,category:"Tất cả",active:true},
  {code:"HELLO20",type:"Số tiền",value:20000,min:0,cap:20000,start:"2026-04-01",end:"2026-04-30",used:50,limit:50,each:1,category:"Tất cả",active:true}
];
const sampleUsers=[
  {email:"minhanh@example.com",name:"Nguyễn Minh Anh",role:"Khách hàng",active:true},
  {email:"baongoc@example.com",name:"Trần Bảo Ngọc",role:"Nhân viên cửa hàng",active:true},
  {email:"khanhlinh@example.com",name:"Phạm Khánh Linh",role:"Nhân viên CSKH",active:false}
];
const sampleReviews=[
  {id:"R01",item:"tiramisu",name:"Nguyễn Minh Anh",rating:5,text:"Bánh mềm và giao đúng giờ.",status:"Chờ duyệt",reply:""},
  {id:"R02",item:"dau",name:"Trần Thu Hà",rating:5,text:"Bánh thơm, phần kem vừa ngọt.",status:"Đã duyệt",reply:""}
];
const seed = {
  products,categories:[{name:"Bánh sinh nhật",active:true},{name:"Tiramisu",active:true},{name:"Croissant",active:true},{name:"Bánh mùa lễ",active:false}],
  orders:sampleOrders,vouchers:sampleVouchers,users:sampleUsers,reviews:sampleReviews,
  cart:[],profile:null,role:"",voucher:"",delivery:"Giao tận nơi",pending:null,lastOrder:"",reviewed:[],voucherUses:{}
};
const storageKey="sweetbakery-nhom3-demo";
let state=structuredClone(seed);
try { Object.assign(state,JSON.parse(localStorage.getItem(storageKey) || "{}")); } catch {}
const save=()=>localStorage.setItem(storageKey,JSON.stringify(state));
const app=document.querySelector("#app"), notice=document.querySelector("#notice");
let noticeTimer;
const esc=value=>String(value ?? "").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"})[c]);
const money=n=>Math.round(n).toLocaleString("vi-VN")+" ₫";
const date=value=>value ? value.split("-").reverse().join("/") : "—";
const fold=s=>String(s).normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/đ/gi,"d").toLowerCase();
const today="2026-05-17";
const find=(list,key,value)=>list.find(item=>item[key]===value);
const p=id=>find(state.products,"id",id);
const o=id=>find(state.orders,"id",id);
const v=code=>find(state.vouchers,"code",code);
const r=id=>find(state.reviews,"id",id);
const cats=()=>state.categories.filter(c=>c.active).map(c=>c.name);
const steps=["Chờ xác nhận","Đã xác nhận","Đã chuẩn bị","Đã đóng gói","Đã bàn giao","Đang giao","Đã giao"];
const methods=["VNPAY-QR","MoMo","Thẻ ATM","Thẻ quốc tế"];
const titles={
  home:"Trang chủ",register:"Đăng ký tài khoản",login:"Đăng nhập",products:"Menu bánh",empty:"Kết quả tìm kiếm",
  detail:"Chi tiết sản phẩm",cart:"Giỏ hàng",checkout:"Đặt hàng và thanh toán",result:"Kết quả thanh toán",
  profile:"Tài khoản của tôi",orders:"Lịch sử đơn hàng",review:"Đánh giá sản phẩm","staff-login":"Đăng nhập nội bộ",
  report:"Báo cáo thống kê",categories:"Quản lý danh mục","admin-products":"Quản lý sản phẩm","edit-product":"Thêm hoặc sửa sản phẩm",
  "admin-orders":"Quản lý đơn hàng","edit-order":"Chi tiết và xử lý đơn",users:"Quản lý người dùng",vouchers:"Quản lý khuyến mãi",
  "edit-voucher":"Tạo hoặc sửa mã khuyến mãi",confirm:"Xác nhận đơn hàng",pack:"Đóng gói và bàn giao",
  moderation:"Duyệt và phản hồi đánh giá"
};
const menus={
  admin:[["report","Tổng quan"],["categories","Danh mục"],["admin-products","Sản phẩm"],["admin-orders","Đơn hàng"],["users","Người dùng"],["vouchers","Khuyến mãi"]],
  store:[["confirm","Xác nhận đơn"],["pack","Đóng gói và giao"]],
  care:[["moderation","Đánh giá"]]
};
const roles={admin:"Quản trị viên",store:"Nhân viên cửa hàng",care:"Nhân viên CSKH"};
const parent={"edit-product":"admin-products","edit-order":"admin-orders","edit-voucher":"vouchers"};
const url=(page,q={})=>"#"+page+(Object.keys(q).length ? "?"+new URLSearchParams(q) : "");
const go=(page,q={})=>{const next=url(page,q); if(location.hash===next) render(); else location.hash=next;};
const link=(label,page,q={},alt=false)=>`<a class="button${alt?" alt":""}" href="${esc(url(page,q))}">${esc(label)}</a>`;
const action=(label,act,id="",alt=false)=>`<button type="button" class="button${alt?" alt slim":""}" data-act="${act}" data-id="${esc(id)}">${esc(label)}</button>`;
const tag=(label,color="")=>`<span class="tag ${color}">${esc(label)}</span>`;
const status=s=>tag(s,s.startsWith("Chờ")?"amber":s.startsWith("Đã hủy")?"gray":s.startsWith("Đã")?"green":"");
const head=(title,sub="")=>`<header class="page-head"><h1>${esc(title)}</h1>${sub?`<p class="muted">${esc(sub)}</p>`:""}</header>`;
const photo=(item,cls="")=>`<img class="${cls}" src="assets/buoi4/${esc(item?.photo || item?.id || "dau")}.webp" alt="${esc(item?.name || "Bánh")}">`;
const form=(type,body,cls="stack")=>`<form class="${cls}" data-form="${type}">${body}</form>`;
const send=label=>`<button class="button" type="submit">${esc(label)}</button>`;
const hidden=(name,value)=>`<input type="hidden" name="${name}" value="${esc(value)}">`;
const field=(label,name,value="",type="text",attrs="")=>`<label class="field">${esc(label)}<input name="${name}" type="${type}" value="${esc(value)}" ${attrs}></label>`;
const area=(label,name,value="",attrs="")=>`<label class="field">${esc(label)}<textarea name="${name}" ${attrs}>${esc(value)}</textarea></label>`;
const select=(label,name,choices,current="",attrs="")=>`<label class="field">${esc(label)}<select name="${name}" ${attrs}>
  ${choices.map(value=>`<option${value===current?" selected":""}>${esc(value)}</option>`).join("")}</select></label>`;
const check=(label,name,on=false,attrs="")=>`<label class="check"><input name="${name}" type="checkbox" ${on?"checked":""} ${attrs}>${esc(label)}</label>`;
const radios=(name,choices,current)=>choices.map(label=>`<label class="check"><input name="${name}" type="radio" value="${esc(label)}" ${label===current?"checked":""}>${esc(label)}</label>`).join("");
const panel=(title,content,cls="")=>`<section class="panel ${cls}">${title?`<h2>${esc(title)}</h2>`:""}${content}</section>`;
const row=content=>`<div class="row">${content}</div>`;
const grid=(content,n=2)=>`<div class="grid${n}">${content}</div>`;
const split=(left,right,cls="")=>`<div class="split ${cls}">${left}${right}</div>`;
const table=(heads,rows)=>`<div class="table-wrap"><table><thead><tr>${heads.map(h=>`<th scope="col">${esc(h)}</th>`).join("")}</tr></thead>
  <tbody>${rows.length?rows.map(cells=>`<tr>${cells.map(value=>`<td>${value}</td>`).join("")}</tr>`).join(""):`<tr><td colspan="${heads.length}">Không có dữ liệu phù hợp.</td></tr>`}</tbody></table></div>`;
const toast=text=>{notice.textContent=text;clearTimeout(noticeTimer);noticeTimer=setTimeout(()=>notice.textContent="",3600);};
const passwordRules=value=>value.length>=8 && /[a-z]/i.test(value) && /\d/.test(value);

function shop(content,q=""){
  return `<header class="top"><div class="wrap"><a class="brand" href="#home">SweetBakery</a>
    <nav class="shop-nav"><a href="#home">Trang chủ</a><a href="#products">Menu bánh</a></nav>
    ${form("search",`<input name="q" aria-label="Tìm bánh" placeholder="Tìm theo tên hoặc hương vị" value="${esc(q)}">${send("Tìm")}`,"search")}
    <div class="actions"><a class="quiet" href="${state.profile?"#profile":"#login"}">${state.profile?"Tài khoản":"Đăng nhập"}</a>
    ${link("Giỏ hàng ("+state.cart.reduce((sum,line)=>sum+line.qty,0)+")","cart")}</div></div></header>
    <main class="wrap main">${content}</main><footer class="footer"><div class="wrap"><span>SweetBakery · Giao bánh giữ lạnh theo khung giờ</span>
    <div class="actions"><a href="#orders">Theo dõi đơn</a><a href="#staff-login">Khu vực nhân viên</a></div></div></footer>`;
}
function consoleFrame(page,role,content){
  const current=parent[page]||page;
  return `<div class="console"><aside class="sidebar"><a class="brand" href="#home">SweetBakery</a><p class="muted">${roles[role]}</p>
    <nav aria-label="Điều hướng nội bộ">${menus[role].map(([id,name])=>`<a href="#${id}" class="${id===current?"active":""}">${name}</a>`).join("")}</nav>
    <a href="#staff-login" style="color:#fff1ed">Đổi vai trò</a></aside>
    <div class="console-body"><header class="console-top"><span>${titles[current]}</span><span>${roles[role]}</span></header><main class="console-main">${content}</main></div></div>`;
}
function cards(list,three=false){
  return `<div class="products${three?" three":""}">${list.map(item=>`<article class="product">
    <a href="${url("detail",{id:item.id})}">${photo(item)}</a><div><h3><a href="${url("detail",{id:item.id})}">${esc(item.name)}</a></h3>
    <div class="row"><span class="price">${money(item.price)}</span><small>${esc(item.category)}</small></div></div></article>`).join("")}</div>`;
}
const available=()=>state.products.filter(item=>item.active && cats().includes(item.category));
function home(){
  return `<section class="hero"><div class="hero-copy"><span class="eyebrow">Bánh sinh nhật làm theo yêu cầu</span>
    <h1>Bánh kem dâu tươi</h1><p class="muted">Chọn kích cỡ, ghi lời chúc và hẹn giờ nhận bánh.</p>
    ${link("Xem menu bánh","products")}</div>${photo(p("dau"))}</section>
    ${row(link("Tất cả bánh","products",{},true)+cats().map(c=>link(c,"products",{category:c},true)).join(""))}
    <h2 class="section-title">Bánh bán chạy</h2>${cards(available().slice(0,4))}`;
}
function auth(register,q){
  const next=q.get("next")==="checkout"?"checkout":"profile";
  const inputs=register?field("Họ và tên *","name","","text","required")+
    grid(field("Email *","email","","email","required")+field("Số điện thoại *","phone","","tel",'required pattern="[0-9]{10}"'))+
    grid(field("Mật khẩu *","password","","password","required minlength=8")+field("Xác nhận mật khẩu *","confirm","","password","required minlength=8"))+
    field("Ngày sinh","birthday","","date")+'<small>Dùng thông tin mẫu khi trình diễn. Mật khẩu từ 8 ký tự, có chữ và số.</small>'+
    check("Tôi đồng ý với điều khoản và chính sách bảo mật.","terms",false,"required")
    :field("Email hoặc số điện thoại","email","","text","required")+field("Mật khẩu","password","","password","required")+
    row(check("Ghi nhớ đăng nhập","remember")+action("Quên mật khẩu","forgot","",true))+
    '<small>Đăng nhập thử bằng thông tin mẫu để đặt bánh.</small>';
  return split(photo(p(register?"dau":"tiramisu")),panel("",head(titles[register?"register":"login"])+
    form(register?"register":"login",hidden("next",next)+inputs+row(send(register?"Đăng ký":"Đăng nhập")+(register?"":action("Đăng nhập mẫu","sample-login",next,true)))+
    `<a href="${url(register?"login":"register",{next})}">${register?"Đã có tài khoản? Đăng nhập":"Chưa có tài khoản? Đăng ký"}</a>`)),"equal auth");
}
function menu(q,empty=false){
  const keyword=q.get("q")||(empty?"bánh xoài":"");
  const category=q.get("category")||"Tất cả", price=q.get("price")||"Tất cả", size=q.get("size")||"Tất cả", flavor=q.get("flavor")||"Tất cả";
  const sort=q.get("sort")||"Bán chạy";
  const items=available().filter(x=>fold([x.name,x.category,...x.flavors].join(" ")).includes(fold(keyword))&&
    (category==="Tất cả"||x.category===category)&&(price==="Tất cả"||(price==="Dưới 300.000 ₫"?x.price<300000:x.price>=300000))&&
    (size==="Tất cả"||x.sizes.includes(size))&&(flavor==="Tất cả"||x.flavors.includes(flavor)));
  if(sort!=="Bán chạy") items.sort((a,b)=>(a.price-b.price)*(sort==="Giá thấp đến cao"?1:-1));
  const pages=Math.max(1,Math.ceil(items.length/12)), page=Math.max(1,Math.min(pages,+q.get("page")||1));
  const filters=panel("Bộ lọc",form("filters",field("Từ khóa","q",keyword)+select("Danh mục","category",["Tất cả",...cats()],category)+
    select("Mức giá","price",["Tất cả","Dưới 300.000 ₫","Từ 300.000 ₫"],price)+select("Kích cỡ","size",["Tất cả","16 cm","20 cm","1 phần"],size)+
    select("Hương vị","flavor",["Tất cả",...new Set(state.products.flatMap(x=>x.flavors))],flavor)+
    select("Sắp xếp","sort",["Bán chạy","Giá thấp đến cao","Giá cao đến thấp"],sort)+row(send("Áp dụng")+link("Bỏ lọc","products",{},true))));
  const results=items.length?cards(items.slice((page-1)*12,page*12),true)+
    `<div class="section-title row"><small>Trang ${page} / ${pages}</small>${page>1?link("Trước","products",{...Object.fromEntries(q),page:page-1},true):""}
    ${page<pages?link("Sau","products",{...Object.fromEntries(q),page:page+1},true):""}</div>`
    :panel("",`<div class="empty"><h2>Không tìm thấy bánh phù hợp</h2><p>Thử từ khóa khác hoặc xóa bộ lọc.</p>${link("Xem tất cả","products",{},true)}</div>`)
      +'<h2 class="section-title">Có thể bạn sẽ thích</h2>'+cards(available().slice(0,3),true);
  return head(keyword?"Kết quả tìm kiếm":titles.products,keyword?"Từ khóa “"+keyword+"” · "+items.length+" kết quả":items.length+" mẫu bánh")
    +split(filters,`<div>${results}</div>`,"with-filter");
}
const unit=line=>p(line.id).price+(line.size==="20 cm"?100000:0);
function detail(q){
  const item=p(q.get("id")||"dau");
  if(!item?.active) return head("Bánh hiện không bán")+link("Xem menu bánh","products");
  const reviews=state.reviews.filter(r=>r.item===item.id&&r.status==="Đã duyệt");
  const controls=hidden("id",item.id)+grid(select("Kích cỡ","size",item.sizes,item.sizes[0],'id="size"')+select("Hương vị","flavor",item.flavors,item.flavors[0]))+
    grid(field("Chữ viết trên bánh","message","","text","maxlength=40")+field("Số lượng","qty",1,"number","required min=1 max=10"))+
    field("Ghi chú cho tiệm","note","","text","maxlength=255")+
    '<p class="note">Cảnh báo dị ứng. Có sữa, lúa mì và có thể có trứng.</p>'+
    row(send("Thêm vào giỏ")+'<button class="button alt" name="buy" value="yes">Mua ngay</button>');
  return `<p class="breadcrumb"><a href="#products">Menu bánh</a> › ${esc(item.category)}</p>`+
    split(photo(item,"detail-image"),panel("",head(item.name)+`<p id="detail-price" class="major-price price">${money(item.price)}</p>`+form("add",controls)),"equal")+
    panel("",`<div class="tabs"><button class="active" type="button" data-tab="description">Mô tả</button>
    <button type="button" data-tab="ingredients">Thành phần</button><button type="button" data-tab="reviews">Đánh giá (${reviews.length})</button></div>
    <div data-pane="description">Bảo quản 2–6 °C. Dùng trong 24 giờ sau khi nhận.</div>
    <div data-pane="ingredients" hidden>${esc(item.ingredients)}</div>
    <div data-pane="reviews" hidden>${reviews.map(x=>`<p><strong>${esc(x.name)} · ${x.rating}/5</strong> — ${esc(x.text)}</p>${x.reply?`<p><small>SweetBakery: ${esc(x.reply)}</small></p>`:""}`).join("")||"Chưa có đánh giá đã duyệt."}</div>`,"section-title");
}

const voucherStatus=item=>!item.active?"Tạm dừng":item.end<today||item.used>=item.limit?"Đã hết hạn":item.start>today?"Sắp diễn ra":"Đang diễn ra";
function totals(code=state.voucher){
  const subtotal=state.cart.reduce((sum,item)=>sum+unit(item)*item.qty,0);
  const shipping=state.delivery==="Giao tận nơi"?25000:0, voucher=v(code);
  let discount=0;
  if(voucher && voucherStatus(voucher)==="Đang diễn ra" && subtotal>=voucher.min && (state.voucherUses[code]||0)<voucher.each){
    const eligible=state.cart.filter(l=>voucher.category==="Tất cả"||p(l.id).category===voucher.category).reduce((sum,l)=>sum+unit(l)*l.qty,0);
    if(eligible){
      discount=voucher.type==="Phần trăm"?eligible*voucher.value/100:voucher.type==="Miễn phí giao"?Math.min(shipping,voucher.value):Math.min(eligible,voucher.value);
      if(voucher.cap) discount=Math.min(voucher.cap,discount);
    }
  }
  discount=Math.round(discount);
  return {subtotal,shipping,discount,total:subtotal+shipping-discount};
}
function summary(checkout=false){
  const t=totals();
  return `<div class="summary"><div><span>Tạm tính</span><strong>${money(t.subtotal)}</strong></div>
  <div><span>Phí giao hàng</span><span>${checkout?money(t.shipping):"Tính khi đặt hàng"}</span></div>
  ${checkout?`<div><span>Giảm giá</span><strong>${money(t.discount)}</strong></div>
    <div class="total"><strong>Tổng thanh toán</strong><strong class="price">${money(t.total)}</strong></div>`
    :link("Tiến hành đặt hàng",state.profile?"checkout":"login",state.profile?{}:{next:"checkout"})}</div>`;
}
function cart(){
  if(!state.cart.length)return head(titles.cart)+panel("",`<div class="empty"><h2>Giỏ hàng đang trống</h2>${link("Xem menu bánh","products")}</div>`);
  const items=state.cart.map((l,i)=>`<div class="cart-line">${photo(p(l.id))}<div><h3>${esc(p(l.id).name)}</h3>
    <small>${esc([l.size,l.flavor,l.message].filter(Boolean).join(" · "))}</small></div>
    <div class="qty">${action("−","minus",i,true)}<strong>${l.qty}</strong>${action("+","plus",i,true)}</div>
    ${row(`<strong class="price">${money(unit(l)*l.qty)}</strong>`+action("Xóa","remove",i,true))}</div>`).join("");
  return head(titles.cart,state.cart.reduce((sum,item)=>sum+item.qty,0)+" sản phẩm")+split(panel("Sản phẩm",items),panel("Tóm tắt đơn hàng",summary()));
}
function checkout(){
  if(!state.cart.length)return cart();
  if(!state.profile)return head("Đăng nhập để đặt bánh")+link("Đăng nhập","login",{next:"checkout"});
  const s=state.pending||state.profile, delivery=state.delivery;
  const controls=grid(field("Người nhận *","name",s.name,"text","required")+field("Số điện thoại *","phone",s.phone,"tel",'required pattern="[0-9]{10}"'))+
    row(radios("delivery",["Giao tận nơi","Nhận tại cửa hàng"],delivery))+
    `<div id="delivery-address" ${delivery==="Giao tận nơi"?"":"hidden"}>${field("Địa chỉ giao *","address",s.address,"text",delivery==="Giao tận nơi"?"required":"")}</div>`+
    grid(field("Ngày nhận *","date",s.date||today,"date",`required min="${today}"`)+
      select("Khung giờ *","slot",["09:00 – 11:00","14:00 – 16:00","16:00 – 18:00"],s.slot||"14:00 – 16:00"))+
    field("Ghi chú giao bánh","note",s.note||"","text","maxlength=255")+
    `<h3>Thanh toán trực tuyến</h3><div class="payment-choices">${radios("payment",methods,s.payment||methods[0])}</div>
      <p class="muted">Thanh toán 100% trước khi xác nhận đơn. Các giao dịch trong demo được mô phỏng.</p>`+
    row(send("Tiếp tục thanh toán")+link("Về giỏ hàng","cart",{},true));
  const voucher=form("voucher",field("Mã ưu đãi","code",state.voucher,"text",'placeholder="BANH10" required')+send("Áp dụng mã"))+
    (state.voucher?`<div class="row section-title"><span class="tag green">${esc(state.voucher)}</span>${action("Bỏ mã","no-voucher","",true)}</div>`:"");
  return head(titles.checkout,"Giỏ hàng › Thông tin nhận bánh › Thanh toán")+split(panel("Thông tin nhận bánh",form("checkout",controls)),
    `<div class="stack">${panel("Tóm tắt đơn hàng",`<div id="summary">${summary(true)}</div>`)}${panel("Mã giảm giá",voucher)}</div>`);
}
function result(q){
  const last=o(state.lastOrder)||state.orders[0], pending=state.pending;
  const success=panel("",tag("Đã thanh toán","green")+
    `<h2 class="section-title">Đặt hàng thành công</h2><p>Mã đơn <strong>${esc(last.id)}</strong> · ${money(last.total)}</p>
    <p class="muted">Đơn đã vào hàng đợi xác nhận.</p><div class="section-title">${link("Xem đơn hàng","orders",{id:last.id})}</div>`);
  const failed=panel("",tag("Có thể thử lại","amber")+
    `<h2 class="section-title">Thanh toán chưa thành công</h2><p>Giỏ hàng của bạn vẫn được lưu.</p>
    <p class="muted">Quay lại để chọn phương thức và thanh toán.</p><div class="section-title">${link("Thử lại","checkout",{},true)}</div>`);
  if(q.get("status")==="success")return head(titles.result)+success;
  if(q.get("status")==="failed")return head(titles.result)+failed;
  if(pending)return head("Xác nhận thanh toán mô phỏng",pending.payment)+
    panel("Số tiền cần thanh toán",`<p class="price major-price">${money(pending.total)}</p><div class="section-title row">
    ${action("Mô phỏng thành công","pay-success")}${action("Mô phỏng thất bại","pay-failed","",true)}</div>`);
  return head(titles.result,"Hai trạng thái có thể hiển thị sau giao dịch")+split(success,failed,"equal");
}
function profile(){
  if(!state.profile)return head("Đăng nhập để xem tài khoản")+link("Đăng nhập","login");
  const a=state.profile;
  const info=form("profile",grid(field("Họ tên","name",a.name,"text","required")+field("Email","email",a.email,"email","required")+
    field("Số điện thoại","phone",a.phone,"tel",'required pattern="[0-9]{10}"')+field("Ngày sinh","birthday",a.birthday,"date"))+send("Lưu thay đổi"));
  return head(titles.profile)+split(panel(a.name,`<div class="stack">${link("Lịch sử đơn","orders",{},true)}
    ${action("Đăng xuất","sign-out","",true)}</div>`),
    `<div class="stack">${panel("Thông tin cá nhân",info)}${panel("Sổ địa chỉ nhận bánh",form("address",field("Địa chỉ mặc định","address",a.address)+send("Lưu địa chỉ")))}
    ${panel("Đổi mật khẩu",form("password",grid(field("Mật khẩu mới","password","","password","required minlength=8")+
    field("Xác nhận mật khẩu","confirm","","password","required minlength=8"))+send("Kiểm tra mật khẩu mẫu")))}</div>`,"with-filter");
}
function orders(q){
  const own=state.orders.filter(x=>x.own || x.email===(state.profile?.email||sampleProfile.email) && x.name!=="Trần Thu Hà");
  const filter=q.get("filter")||"Tất cả";
  const list=own.filter(x=>filter==="Tất cả"||x.status===filter);
  const selected=find(own,"id",q.get("id"))||list[0];
  const timeline=selected?steps.indexOf(selected.status):-1;
  const details=selected?panel("Theo dõi "+selected.id,`<p>${esc(selected.delivery)} · ${date(selected.date)} · ${esc(selected.slot)}</p>
    <p class="muted">${selected.tracking?"Mã vận đơn "+esc(selected.tracking):esc(selected.delivery==="Giao tận nơi"?selected.address:"Nhận tại cửa hàng")}</p>
    ${timeline>=0?`<ol class="timeline">${steps.map((s,i)=>`<li>${tag(s,i<timeline?"green":i===timeline?"":"gray")}</li>`).join("")}</ol>`:status(selected.status)}
    ${(selected.lines||[{id:selected.item,qty:1,size:"16 cm"}]).map(l=>`<p>${esc(p(l.id)?.name)} × ${l.qty} · ${esc(l.size)}</p>`).join("")}`,"section-title"):"";
  return head(titles.orders)+row(["Tất cả","Chờ xác nhận","Đang giao","Đã giao","Đã hủy"].map(s=>link(s,"orders",{filter:s},s!==filter)).join(""))+
    `<div class="section-title">${table(["Mã đơn","Ngày nhận","Tổng tiền","Trạng thái","Thao tác"],list.map(x=>[
    esc(x.id),date(x.date),money(x.total),status(x.status),row(link("Chi tiết","orders",{id:x.id,filter},true)+
    (x.status==="Chờ xác nhận"?action("Hủy","cancel",x.id,true):"")+
    (x.status==="Đã giao"&&!state.reviewed.includes(x.id)?link("Đánh giá","review",{id:x.id},true):""))
    ]))}</div>${details}`;
}
function review(q){
  const selected=o(q.get("id")||"BN-260510-006");
  if(!selected||selected.status!=="Đã giao"||state.reviewed.includes(selected.id))return head("Chưa thể đánh giá đơn hàng")+link("Xem đơn hàng","orders");
  const fields=hidden("id",selected.id)+hidden("rating",5)+`<div class="rating" aria-label="Chấm điểm">
    ${[1,2,3,4,5].map(n=>`<button type="button" data-star="${n}" aria-label="${n} sao" aria-pressed="true">★</button>`).join("")}</div>`+
    area("Nhận xét · tối thiểu 10 ký tự","text","","required minlength=10 maxlength=500")+
    field("Ảnh thực tế · tối đa 3 ảnh JPG/PNG","photos","","file",'accept="image/jpeg,image/png" multiple')+
    '<p class="muted">Mỗi ảnh dưới 5 MB. Đánh giá sẽ hiển thị sau khi được duyệt.</p>'+row(send("Gửi đánh giá")+link("Quay lại","orders",{},true));
  return `<div style="max-width:760px;margin-inline:auto">${panel("",head(titles.review,p(selected.item).name+" · "+selected.id)+form("review",fields))}</div>`;
}

function staffLogin(){
  const choices=Object.entries(roles).map(([role,name])=>action(name,"role",role,true)).join("");
  return split(`<aside class="sidebar"><a class="brand" href="#home">SweetBakery</a>
    <p class="muted">Khu vực nhân viên</p><a href="#home" style="color:white">Về cửa hàng</a></aside>`,
    panel("",head(titles["staff-login"],"Chọn vai trò để mở khu vực tương ứng trong bản demo.")+
    form("staff",field("Email nội bộ mẫu","email","nhanvien@example.com","email","required")+
    select("Vai trò","role",Object.values(roles),roles.admin)+send("Đăng nhập mẫu"))+
    `<div class="row section-title">${choices}</div>`),"console-login");
}

const toolbar=html=>`<div class="toolbar">${html}</div>`;
const filterInput=(label,value="")=>`<input aria-label="${esc(label)}" name="query" placeholder="${esc(label)}" value="${esc(value)}">`;
function filterToolbar(q,placeholder,statuses=[],extra=""){
  return toolbar(form("list-filter",filterInput(placeholder,q.get("query")||"")+
    (statuses.length?select("Trạng thái","status",["Tất cả",...statuses],q.get("status")||"Tất cả"):"")+send("Lọc"),"row")+extra);
}
function filtered(items,q,fields,statusFn=()=>""){
  const query=fold(q.get("query")||""), status=q.get("status")||"Tất cả";
  return items.filter(x=>fields.some(f=>fold(x[f]||"").includes(query)) && (status==="Tất cả"||statusFn(x)===status));
}
function reportStats(range){
  return range==="Tháng 04/2026" ? {
    values:[["Doanh thu thuần","22.475.000 ₫"],["Đơn đã giao","74"],["Giá trị đơn trung bình","303.716 ₫"],["Tỷ lệ giao thành công","94%"]],
    bars:[30,52,60,74], top:[25,20,17,12]
  } : {
    values:[["Doanh thu thuần","28.616.000 ₫"],["Đơn đã giao","92"],["Giá trị đơn trung bình","311.043 ₫"],["Tỷ lệ giao thành công","96%"]],
    bars:[38,61,69,91], top:[32,25,19,16]
  };
}
function report(q){
  const range=q.get("range")||"Tháng 05/2026";
  const {values,bars,top}=reportStats(range);
  return head(titles.report,"Dữ liệu minh họa theo kỳ báo cáo")+toolbar(form("report-filter",
    select("Kỳ báo cáo","range",["Tháng 05/2026","Tháng 04/2026"],range)+send("Xem"),"row")+
    `<div class="row push">${action("Xuất CSV","csv","",true)}${action("In / lưu PDF","print","",true)}</div>`)+
    `<div class="kpis">${values.map(([label,value])=>panel("",`<small>${label}</small><strong>${value}</strong>`,"kpi")).join("")}</div>`+
    split(panel("Doanh thu theo tuần",`<div class="chart" role="img" aria-label="Doanh thu tăng qua bốn tuần">
    ${bars.map((h,i)=>`<div style="--height:${h}%"><span>Tuần ${i+1}</span></div>`).join("")}</div>`,"chart-panel"),
    panel("Bánh bán chạy",table(["Sản phẩm","Số lượng"],products.map((item,i)=>[esc(item.name),top[i]]))));
}
function categoriesPage(q){
  const visible=x=>x.active?"Hiển thị":"Đã ẩn", items=filtered(state.categories,q,["name"],visible);
  const edit=find(state.categories,"name",q.get("edit"));
  const fields=hidden("old",edit?.name||"")+field("Tên danh mục *","name",edit?.name||"","text","required maxlength=80")+
    row(send(edit?"Lưu danh mục":"Thêm danh mục")+link("Hủy","categories",{},true));
  return head(titles.categories)+filterToolbar(q,"Tìm danh mục",["Hiển thị","Đã ẩn"],`<div class="push">${link("Thêm danh mục","categories",{new:1})}</div>`)+
    table(["Thứ tự","Danh mục","Số bánh","Trạng thái","Thao tác"],items.map((x,i)=>[
      i+1,esc(x.name),state.products.filter(p=>p.category===x.name).length,tag(visible(x),x.active?"green":"gray"),
      row(link("Sửa","categories",{edit:x.name},true)+action(x.active?"Ẩn":"Hiện","toggle-category",x.name,true))
    ]))+
    (edit||q.has("new")?panel(edit?"Sửa danh mục":"Thêm danh mục",form("category",fields),"section-title"):
      '<p class="muted section-title">Chuyển hết sản phẩm sang danh mục khác trước khi xóa danh mục.</p>');
}
function adminProducts(q){
  const visible=x=>x.active?"Đang bán":"Ngừng bán";
  return head(titles["admin-products"])+filterToolbar(q,"Tìm tên hoặc SKU",["Đang bán","Ngừng bán"],`<div class="push">${link("Thêm sản phẩm","edit-product",{new:1})}</div>`)+
    table(["SKU","Sản phẩm","Danh mục","Giá từ","Sức làm/ngày","Trạng thái","Thao tác"],filtered(state.products,q,["sku","name","category"],visible).map(x=>[
      esc(x.sku),esc(x.name),esc(x.category),money(x.price),x.capacity,tag(visible(x),x.active?"green":"gray"),
      row(link("Sửa","edit-product",{id:x.id},true)+action(x.active?"Ngừng bán":"Mở bán","toggle-product",x.id,true))
    ]));
}
function editProduct(q){
  const item=q.has("new")?{}:(p(q.get("id")||"dau")||{});
  const fields=hidden("id",item.id)+grid(field("Tên sản phẩm *","name",item.name,"text","required maxlength=90")+
    field("SKU *","sku",item.sku,"text","required maxlength=30")+
    select("Danh mục","category",[...new Set([...cats(),item.category].filter(Boolean))],item.category)+
    field("Đơn giá nhỏ nhất *","price",item.price,"number","required min=1 step=1000")+
    field("Kích cỡ (ngăn cách bằng dấu phẩy)","sizes",item.sizes?.join(", ")||"16 cm, 20 cm","text","required")+
    field("Hương vị (ngăn cách bằng dấu phẩy)","flavors",item.flavors?.join(", ")||"Vani","text","required")+
    field("Sức làm tối đa mỗi ngày *","capacity",item.capacity,"number","required min=1")+
    select("Ảnh minh họa","photo",products.map(x=>x.id),item.photo||item.id||"dau"))+
    area("Thành phần","ingredients",item.ingredients)+
    '<p class="note">Trang chi tiết hiển thị cảnh báo dị ứng và thông tin bảo quản.</p>'+
    row(send("Lưu sản phẩm")+link("Hủy","admin-products",{},true));
  return head(item.id?"Sửa sản phẩm":"Thêm sản phẩm")+split(panel("Thông tin bánh",form("product",fields)),
    panel("Xem ảnh minh họa",photo(item)));
}
function adminOrders(q){
  return head(titles["admin-orders"])+filterToolbar(q,"Tìm mã đơn hoặc số điện thoại",[...steps,"Đã hủy"])+
    table(["Mã đơn","Khách hàng","Ngày nhận","Khung giờ","Tổng tiền","Trạng thái","Thao tác"],
      filtered(state.orders,q,["id","name","phone","date"],x=>x.status).map(x=>[
      esc(x.id),esc(x.name),date(x.date),esc(x.slot),money(x.total),status(x.status),link("Chi tiết","edit-order",{id:x.id},true)
    ]));
}
function editOrder(q){
  const x=o(q.get("id")||"BN-260516-019");
  if(!x)return head("Không tìm thấy đơn")+link("Danh sách đơn","admin-orders");
  const current=steps.indexOf(x.status), next=current>=0&&current<steps.length-1?steps[current+1]:null;
  const lines=x.lines||[{id:x.item,qty:1,size:"16 cm"}];
  const summary=panel("Thông tin đơn hàng",status(x.status)+
    `<p class="section-title">${esc(x.name)} · ${esc(x.phone)}</p><p>${esc(x.delivery)} · ${date(x.date)} · ${esc(x.slot)}</p>
    <p class="muted">${esc(x.delivery==="Giao tận nơi"?x.address:"Nhận tại cửa hàng")}</p>
    <div class="section-title">${table(["Bánh","Kích cỡ","Số lượng"],lines.map(l=>[esc(p(l.id)?.name),esc(l.size),l.qty]))}</div>
    <p class="section-title"><strong>Tổng tiền: ${money(x.total)}</strong></p>
    <h3>Lịch sử xử lý</h3><p class="muted">${esc(x.reason||"Cổng thanh toán xác nhận giao dịch mẫu.")}</p>`);
  const options=[next,steps.includes(x.status)&&x.status!=="Đã giao"?"Đã hủy – Chờ hoàn tiền":null].filter(Boolean);
  const update=options.length?form("order-status",hidden("id",x.id)+select("Trạng thái tiếp theo","status",options)+
    area("Lý do cập nhật *","reason","","required maxlength=255")+send("Cập nhật trạng thái")):'<p>Đơn đã kết thúc.</p>';
  return head(titles["edit-order"],x.id)+split(summary,panel("Xử lý đơn",update));
}
function users(q){
  const visible=x=>x.active?"Hoạt động":"Đã khóa";
  return head(titles.users)+filterToolbar(q,"Tìm tên, email hoặc vai trò",["Hoạt động","Đã khóa"],`<div class="push">${link("Cấp tài khoản","users",{new:1})}</div>`)+
    table(["Họ tên","Email","Vai trò","Trạng thái","Thao tác"],filtered(state.users,q,["name","email","role"],visible).map(x=>[
      esc(x.name),esc(x.email),esc(x.role),tag(visible(x),x.active?"green":"gray"),action(x.active?"Khóa":"Mở khóa","toggle-user",x.email,true)
    ]))+(q.has("new")?panel("Cấp tài khoản nội bộ",form("user",grid(field("Họ tên","name","","text","required")+field("Email","email","","email","required")+
    select("Vai trò","role",Object.values(roles)))+send("Tạo tài khoản mẫu")),"section-title"):"");
}
function vouchers(q){
  return head(titles.vouchers)+filterToolbar(q,"Tìm mã ưu đãi",["Đang diễn ra","Sắp diễn ra","Đã hết hạn","Tạm dừng"],
    `<div class="push">${link("Tạo mã khuyến mãi","edit-voucher",{new:1})}</div>`)+
    table(["Mã","Loại ưu đãi","Thời hạn","Lượt dùng","Trạng thái","Thao tác"],filtered(state.vouchers,q,["code","type"],voucherStatus).map(x=>[
      esc(x.code),esc(x.type),date(x.start)+" – "+date(x.end),x.used+" / "+x.limit,
      tag(voucherStatus(x),voucherStatus(x)==="Đang diễn ra"?"green":voucherStatus(x)==="Sắp diễn ra"?"amber":"gray"),
      row(link("Sửa","edit-voucher",{code:x.code},true)+action(x.active?"Tạm dừng":"Tiếp tục","toggle-voucher",x.code,true))
    ]));
}
function editVoucher(q){
  const x=q.has("new")?{}:(v(q.get("code")||"BANH10")||{});
  const fields=hidden("old",x.code)+grid(field("Mã ưu đãi *","code",x.code,"text","required maxlength=30")+
    select("Loại giảm","type",["Phần trăm","Số tiền","Miễn phí giao"],x.type)+field("Giá trị giảm *","value",x.value,"number","required min=1")+
    field("Đơn tối thiểu","min",x.min||0,"number","required min=0")+field("Giảm tối đa","cap",x.cap||0,"number","required min=0")+
    select("Phạm vi","category",["Tất cả",...cats()],x.category)+field("Ngày bắt đầu","start",x.start||today,"date","required")+
    field("Ngày kết thúc","end",x.end,"date","required")+field("Tổng lượt","limit",x.limit||100,"number","required min=1")+
    field("Lượt mỗi khách","each",x.each||1,"number","required min=1"),3)+
    '<p class="muted">Mỗi đơn áp dụng tối đa một mã ưu đãi.</p>'+row(send("Lưu mã ưu đãi")+link("Hủy","vouchers",{},true));
  return head(titles["edit-voucher"])+panel("Điều kiện áp dụng",form("save-voucher",fields));
}
function confirm(){
  const pending=state.orders.filter(x=>x.status==="Chờ xác nhận");
  return head(titles.confirm)+`<p class="note good section-title">${pending.length} đơn đã thanh toán đủ đang chờ xác nhận.</p>`+
    table(["Mã đơn","Khách hàng","Khung giờ nhận","Thanh toán","Thao tác"],pending.map(x=>[
    esc(x.id),esc(x.name),date(x.date)+" · "+esc(x.slot),tag("Đã thanh toán","green"),action("Xác nhận","confirm",x.id,true)]));
}
function pack(q){
  const active=state.orders.filter(x=>["Đã xác nhận","Đã chuẩn bị","Đã đóng gói","Đã bàn giao"].includes(x.status));
  const x=find(active,"id",q.get("id"))||active.find(x=>x.status==="Đã chuẩn bị")||active[0];
  if(!x)return head(titles.pack)+panel("Chưa có đơn đang chuẩn bị",link("Xem đơn chờ xác nhận","confirm",{},true));
  const checklist=form("packing",hidden("id",x.id)+check("Đúng mẫu, kích cỡ và chữ trên bánh","correct",false,"required")+
    check("Có túi đá để giữ lạnh","cold",false,"required")+check("Dán tem niêm phong và mã đơn","seal",false,"required")+
    (x.status==="Đã xác nhận"?action("Đánh dấu đã chuẩn bị","prepare",x.id):x.status==="Đã chuẩn bị"?send("Xác nhận đã đóng gói"):status(x.status)));
  const shipping=form("ship",hidden("id",x.id)+select("Đơn vị vận chuyển","carrier",["Ahamove","GrabExpress","Giao Hàng Tiết Kiệm"],x.carrier)+
    field("Mã vận đơn","tracking",x.tracking||"AHM-"+x.id.slice(-3),"text","required")+
    (x.status==="Đã đóng gói"?send("Xác nhận bàn giao"):x.status==="Đã bàn giao"?tag("Đã bàn giao","green"):'<p class="muted">Hoàn tất đóng gói trước khi bàn giao.</p>'));
  return head(titles.pack,x.id+" · "+x.status)+toolbar(form("pack-select",select("Đơn cần xử lý","id",active.map(x=>x.id),x.id)+send("Mở đơn"),"row"))+
    split(panel("Kiểm tra đóng gói",checklist),panel("Bàn giao vận chuyển",shipping),"equal");
}
function moderation(q){
  const pending=state.reviews.find(x=>x.status==="Chờ duyệt"), approved=state.reviews.find(x=>x.status==="Đã duyệt"&&!x.reply);
  return head(titles.moderation)+filterToolbar(q,"Tìm khách hàng hoặc nội dung",["Chờ duyệt","Đã duyệt","Đã ẩn"])+
    table(["Khách hàng","Bánh","Điểm","Nội dung","Trạng thái","Thao tác"],filtered(state.reviews,q,["name","text"],x=>x.status).map(x=>[
      esc(x.name),esc(p(x.item)?.name),x.rating+"/5",esc(x.text),status(x.status),
      x.status==="Chờ duyệt"?action("Duyệt","approve",x.id,true):x.reply?tag("Đã phản hồi","green"):"—"
    ]))+`<div class="section-title">${split(
      panel("Ẩn đánh giá vi phạm",pending?form("hide-review",select("Đánh giá","id",state.reviews.filter(x=>x.status==="Chờ duyệt").map(x=>x.id),pending.id)+
        area("Lý do ẩn *","reason","","required maxlength=255")+send("Xác nhận ẩn")):"Không có đánh giá chờ xử lý."),
      panel("Phản hồi đánh giá đã duyệt",approved?form("reply-review",select("Đánh giá","id",state.reviews.filter(x=>x.status==="Đã duyệt"&&!x.reply).map(x=>x.id),approved.id)+
        area("Phản hồi chính thức *","text","","required maxlength=500")+send("Gửi phản hồi")):"Các đánh giá đã duyệt đều có phản hồi."),
      "equal")}</div>`;
}

const views={
  home,register:q=>auth(true,q),login:q=>auth(false,q),products:menu,empty:q=>menu(q,true),detail,cart,checkout,result,profile,orders,review,
  "staff-login":staffLogin,report,categories:categoriesPage,"admin-products":adminProducts,"edit-product":editProduct,
  "admin-orders":adminOrders,"edit-order":editOrder,users,vouchers,"edit-voucher":editVoucher,confirm,pack,moderation
};
function route(){
  const [requested,query=""]=location.hash.slice(1).split("?");
  return [Object.hasOwn(views,requested)?requested:"home",new URLSearchParams(query)];
}
function render(){
  const [page,q]=route(), section=parent[page]||page;
  const role=Object.keys(menus).find(name=>menus[name].some(([id])=>id===section));
  const sameRole=!role||state.role===role;
  document.title=(sameRole?titles[page]:titles["staff-login"])+" · SweetBakery";
  if(role&&!sameRole)app.innerHTML=staffLogin();
  else {
    const content=views[page](q);
    app.innerHTML=role?consoleFrame(page,role,content):page==="staff-login"?content:shop(content,q.get("q")||"");
  }
}
function loginAs(role){
  if(!Object.hasOwn(roles,role))return;
  state.role=role;
  save();
  go(menus[role][0][0]);
}
function keepCheckout(){
  const element=app.querySelector('form[data-form="checkout"]');
  if(!element)return;
  const {name,phone,address,date,slot,note,payment}=Object.fromEntries(new FormData(element));
  state.pending={name,phone,address,date,slot,note,payment};
}
function finish(message,page,params={}){
  save();
  if(page)go(page,params);else render();
  if(message)toast(message);
}
function changeQty(index,delta){
  const item=state.cart[index];
  if(!item)return;
  if(item.qty+delta>Math.min(p(item.id).capacity,10))return toast("Số lượng vượt giới hạn đặt bánh.");
  if(item.qty+delta<=0)state.cart.splice(index,1);else item.qty+=delta;
  finish();
}

app.addEventListener("change",e=>{
  const input=e.target;
  if(input.id==="size"){
    const id=input.form.elements.id.value;
    app.querySelector("#detail-price").textContent=money(unit({id,size:input.value}));
  }
  if(input.name==="delivery"){
    state.delivery=input.value;
    const address=app.querySelector("#delivery-address");
    address.hidden=input.value!=="Giao tận nơi";
    address.querySelector("input").required=!address.hidden;
    app.querySelector("#summary").innerHTML=summary(true);
    save();
  }
});

app.addEventListener("click",e=>{
  const tab=e.target.closest("[data-tab]");
  if(tab){
    app.querySelectorAll("[data-tab]").forEach(x=>x.classList.toggle("active",x===tab));
    app.querySelectorAll("[data-pane]").forEach(x=>x.hidden=x.dataset.pane!==tab.dataset.tab);
    return;
  }
  const star=e.target.closest("[data-star]");
  if(star){
    star.form.elements.rating.value=star.dataset.star;
    star.form.querySelectorAll("[data-star]").forEach(x=>{
      const selected=+x.dataset.star<=+star.dataset.star;
      x.textContent=selected?"★":"☆";
      x.setAttribute("aria-pressed",String(selected));
    });
    return;
  }
  const button=e.target.closest("[data-act]");
  if(!button)return;
  const {act,id}=button.dataset;
  switch(act){
    case "sample-login": state.profile={...sampleProfile}; finish("Đã đăng nhập tài khoản mẫu.",id); break;
    case "sign-out": state.profile=null; state.pending=null; state.voucher=""; finish("Đã đăng xuất.","home"); break;
    case "forgot": toast("Bản demo dùng nút Đăng nhập mẫu. Không gửi email đặt lại mật khẩu."); break;
    case "role": loginAs(id); break;
    case "minus": changeQty(+id,-1); break;
    case "plus": changeQty(+id,1); break;
    case "remove": state.cart.splice(+id,1); finish("Đã xóa sản phẩm."); break;
    case "no-voucher": keepCheckout(); state.voucher=""; finish("Đã bỏ mã giảm giá."); break;
    case "pay-failed":
      if(state.pending?.total)go("result",{status:"failed"});
      break;
    case "pay-success": {
      const d=state.pending;
      if(!d?.total || !state.cart.length || !state.profile)break;
      const orderId="BN-DEMO-"+Date.now().toString(36).toUpperCase();
      state.orders.unshift({...d,id:orderId,item:state.cart[0].id,lines:structuredClone(state.cart),
        email:state.profile.email,status:"Chờ xác nhận",own:true});
      if(d.voucher){
        v(d.voucher).used++;
        state.voucherUses[d.voucher]=(state.voucherUses[d.voucher]||0)+1;
      }
      state.lastOrder=orderId; state.pending=null; state.voucher=""; state.cart=[];
      finish("", "result",{status:"success"});
      break;
    }
    case "cancel":
      if(o(id)?.status==="Chờ xác nhận"){
        const dlg=document.createElement("dialog");
        dlg.className="dialog";
        dlg.innerHTML='<h2>Hủy đơn hàng?</h2>'+form("cancel",hidden("id",id)+
          select("Lý do hủy","reason",["Đổi mẫu bánh","Đổi giờ nhận bánh","Lý do cá nhân"])+
          row(send("Xác nhận hủy")+'<button type="button" class="button alt" data-act="close-dialog">Quay lại</button>'));
        app.appendChild(dlg); dlg.addEventListener("close",()=>dlg.remove(),{once:true}); dlg.showModal();
      }
      break;
    case "close-dialog": button.closest("dialog")?.close(); break;
    case "toggle-category": {const x=find(state.categories,"name",id);if(x){x.active=!x.active;finish("Đã cập nhật danh mục.");}break;}
    case "toggle-product": {const x=p(id);if(x){x.active=!x.active;finish("Đã cập nhật sản phẩm.");}break;}
    case "toggle-user": {const x=find(state.users,"email",id);if(x){x.active=!x.active;finish("Đã cập nhật tài khoản mẫu.");}break;}
    case "toggle-voucher": {const x=v(id);if(x){x.active=!x.active;finish("Đã cập nhật mã ưu đãi.");}break;}
    case "confirm":
      if(o(id)?.status==="Chờ xác nhận"){o(id).status="Đã xác nhận";finish("Đã xác nhận đơn.","pack",{id});}
      break;
    case "prepare":
      if(o(id)?.status==="Đã xác nhận"){o(id).status="Đã chuẩn bị";finish("Đơn đã chuẩn bị xong.");}
      break;
    case "approve":
      if(r(id)?.status==="Chờ duyệt"){r(id).status="Đã duyệt";finish("Đã công khai đánh giá.");}
      break;
    case "print": window.print();break;
    case "csv": {
      const [,q]=route();
      const stats=reportStats(q.get("range"));
      const blob=new Blob(["\ufeffChỉ số;Giá trị\n"+stats.values.map(item=>item.join(";")).join("\n")],{type:"text/csv;charset=utf-8"});
      const uri=URL.createObjectURL(blob), link=document.createElement("a");
      link.href=uri; link.download="bao-cao-sweetbakery.csv"; link.click(); setTimeout(()=>URL.revokeObjectURL(uri),1000);
      break;
    }
  }
});

app.addEventListener("submit",e=>{
  const f=e.target;
  if(!f.dataset.form)return;
  e.preventDefault();
  const d=Object.fromEntries(new FormData(f,e.submitter));
  const [page]=route();
  switch(f.dataset.form){
    case "search": case "filters": go("products",d);break;
    case "list-filter": go(page,d);break;
    case "report-filter": go("report",d);break;
    case "pack-select": go("pack",d);break;
    case "register":
      if(!passwordRules(d.password))return toast("Mật khẩu phải có từ 8 ký tự, gồm chữ và số.");
      if(d.password!==d.confirm)return toast("Xác nhận mật khẩu chưa trùng khớp.");
      state.profile={name:d.name.trim(),email:d.email,phone:d.phone,birthday:d.birthday,address:""};
      finish("Đã tạo hồ sơ mẫu.",d.next);break;
    case "login":
      if(d.email!==sampleProfile.email && d.email!==sampleProfile.phone)return toast("Dùng minhanh@example.com hoặc nút Đăng nhập mẫu.");
      state.profile={...sampleProfile};finish("Đã đăng nhập tài khoản mẫu.",d.next);break;
    case "staff": loginAs(Object.keys(roles).find(key=>roles[key]===d.role));break;
    case "profile":
      if(!state.profile)break;
      if(d.birthday!==state.profile.birthday && state.profile.birthUpdate===today.slice(0,4))return toast("Ngày sinh chỉ sửa được một lần mỗi năm.");
      if(d.birthday!==state.profile.birthday)state.profile.birthUpdate=today.slice(0,4);
      Object.assign(state.profile,d);finish("Đã lưu thông tin cá nhân.");break;
    case "address":
      if(state.profile){state.profile.address=d.address.trim();finish("Đã lưu địa chỉ.");}break;
    case "password":
      if(!passwordRules(d.password)||d.password!==d.confirm)return toast("Mật khẩu phải hợp lệ và xác nhận phải trùng khớp.");
      f.reset();toast("Mật khẩu mẫu hợp lệ.");break;
    case "add": {
      const {id,size,flavor,message,note}=d, item=p(id), quantity=Number(d.qty);
      if(!item?.active || !Number.isInteger(quantity) || quantity<1 || !item.sizes.includes(size) || !item.flavors.includes(flavor))break;
      const existing=state.cart.find(l=>l.id===id&&l.size===size&&l.flavor===flavor&&l.message===message&&l.note===note);
      if(quantity+(existing?.qty||0)>Math.min(item.capacity,10))return toast("Số lượng vượt giới hạn đặt bánh.");
      if(existing)existing.qty+=quantity;else state.cart.push({id,size,flavor,message,note,qty:quantity});
      finish("Đã thêm vào giỏ.",d.buy?"cart":undefined);break;
    }
    case "voucher": {
      const code=d.code.trim().toUpperCase();
      if(!totals(code).discount)return toast("Mã giảm giá hết hạn hoặc đơn chưa đủ điều kiện.");
      keepCheckout();state.voucher=code;finish("Đã áp dụng mã giảm giá.");break;
    }
    case "checkout": {
      if(!state.profile||!state.cart.length)break;
      if(state.cart.some(line=>!p(line.id)?.active))return toast("Giỏ có sản phẩm đã ngừng bán. Vui lòng cập nhật giỏ.");
      state.delivery=d.delivery;
      const costs=totals();
      state.pending={...d,...costs,voucher:costs.discount?state.voucher:""};
      finish("","result");break;
    }
    case "cancel":
      if(o(d.id)?.status==="Chờ xác nhận"){Object.assign(o(d.id),{status:"Đã hủy",reason:d.reason});finish("Đã hủy đơn và ghi nhận hoàn tiền mô phỏng.");}
      break;
    case "review": {
      const x=o(d.id), files=Array.from(f.elements.photos.files);
      if(!x||x.status!=="Đã giao"||state.reviewed.includes(x.id))break;
      if(d.text.trim().length<10)return toast("Nhận xét cần tối thiểu 10 ký tự.");
      if(files.length>3||files.some(file=>file.size>=5*1024*1024||!["image/jpeg","image/png"].includes(file.type)))return toast("Chọn tối đa 3 ảnh JPG/PNG dưới 5 MB.");
      state.reviewed.push(x.id);
      state.reviews.unshift({id:"R"+Date.now(),item:x.item,name:x.name,rating:+d.rating,text:d.text.trim(),status:"Chờ duyệt",reply:""});
      finish("Đã gửi đánh giá, đang chờ duyệt.","orders",{id:x.id});break;
    }
    case "category": {
      const name=d.name.trim(), old=find(state.categories,"name",d.old);
      if(!name||state.categories.some(x=>fold(x.name)===fold(name)&&x!==old))return toast("Tên danh mục bị trùng hoặc để trống.");
      if(old){old.name=name;state.products.filter(x=>x.category===d.old).forEach(x=>x.category=name);state.vouchers.filter(x=>x.category===d.old).forEach(x=>x.category=name);}
      else state.categories.push({name,active:true});
      finish("Đã lưu danh mục.","categories");break;
    }
    case "product": {
      const old=p(d.id), names=value=>[...new Set(value.split(",").map(s=>s.trim()).filter(Boolean))];
      if(!d.sku.trim()||state.products.some(x=>x!==old&&fold(x.sku)===fold(d.sku)))return toast("SKU trùng hoặc để trống.");
      const updates={name:d.name.trim(),sku:d.sku.trim(),category:d.category,price:+d.price,capacity:+d.capacity,
        sizes:names(d.sizes),flavors:names(d.flavors),photo:d.photo,ingredients:d.ingredients};
      if(!updates.name||!updates.sizes.length||!updates.flavors.length||!updates.category)return toast("Nhập tên, danh mục, kích cỡ và hương vị.");
      if(old)Object.assign(old,updates);else state.products.push({...updates,id:"sp-"+Date.now(),active:true});
      finish("Đã lưu sản phẩm.","admin-products");break;
    }
    case "user":
      if(state.users.some(x=>fold(x.email)===fold(d.email)))return toast("Email đã tồn tại.");
      state.users.push({...d,active:true});finish("Đã cấp tài khoản mẫu.","users");break;
    case "save-voucher": {
      const old=v(d.old), code=d.code.trim().toUpperCase();
      if(!code||state.vouchers.some(x=>x!==old&&x.code===code)||d.end<d.start||(d.type==="Phần trăm"&&+d.value>100))
        return toast("Kiểm tra mã, thời hạn và tỷ lệ giảm.");
      const item={...d,code,value:+d.value,min:+d.min,cap:+d.cap,limit:+d.limit,each:+d.each};
      delete item.old;
      if(old)Object.assign(old,item);else state.vouchers.push({...item,active:true,used:0});
      finish("Đã lưu mã ưu đãi.","vouchers");break;
    }
    case "order-status": {
      const x=o(d.id);
      if(x&&d.reason.trim()){x.status=d.status;x.reason=d.reason.trim();finish("Đã cập nhật trạng thái.");}
      break;
    }
    case "packing":
      if(o(d.id)?.status==="Đã chuẩn bị"&&d.correct&&d.cold&&d.seal){o(d.id).status="Đã đóng gói";finish("Đã xác nhận đóng gói.");}break;
    case "ship":
      if(o(d.id)?.status==="Đã đóng gói"&&d.tracking.trim()){Object.assign(o(d.id),{status:"Đã bàn giao",carrier:d.carrier,tracking:d.tracking.trim()});finish("Đã lưu vận đơn.");}break;
    case "hide-review":
      if(r(d.id)?.status==="Chờ duyệt"&&d.reason.trim()){Object.assign(r(d.id),{status:"Đã ẩn",reason:d.reason.trim()});finish("Đã ẩn đánh giá.");}break;
    case "reply-review":
      if(r(d.id)?.status==="Đã duyệt"&&!r(d.id).reply&&d.text.trim()){r(d.id).reply=d.text.trim();finish("Đã gửi phản hồi.");}break;
  }
});

window.addEventListener("hashchange",()=>{window.scrollTo(0,0);render();});
render();
