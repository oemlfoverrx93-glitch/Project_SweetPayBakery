// Runs against the isolated test server, never the user's normal database.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const {request,chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const baseURL=process.env.SWEETPAY_TEST_URL || 'http://localhost:18081/SweetBakery';
assert(baseURL.includes('localhost:18081/'), 'Only the isolated server on port 18081 is allowed');
let count=0;
function ok(value,name){assert(value,name);console.log('PASS '+name);count++;}
async function page(ctx,url){const res=await ctx.get(baseURL+url);const html=await res.text();if(res.status()!==200)fs.writeFileSync('.tools/http-error.html',html);assert.equal(res.status(),200,url);return html;}
function token(html){const m=html.match(/name="csrfToken" value="([^"]+)"/);assert(m,'CSRF token rendered');return m[1];}
async function login(email,password){const ctx=await request.newContext();await page(ctx,'/login');const res=await ctx.post(baseURL+'/login',{form:{email,password},maxRedirects:0});assert.equal(res.status(),302);return ctx;}
function formId(html,needle,kind){const index=html.indexOf(needle);assert(index>=0,needle);const trStart=html.lastIndexOf('<tr',index),trEnd=html.indexOf('</tr>',index);const row=html.slice(trStart,trEnd);const found=row.match(new RegExp('/admin/'+kind+'\\?edit=(\\d+)'));assert(found,row);return found[1];}
async function main(){
 const admin=await login('admin@sweetpay.com','admin123'),store=await login('store@ops.test','TestPassword123!'),driver=await login('driver@ops.test','TestPassword123!'),customer=await login('vana@gmail.com','123456'),other=await login('other@ops.test','TestPassword123!');
 for(const url of ['/admin/dashboard','/admin/fulfillment','/admin/fulfillment?id=2','/admin/reconciliation','/admin/categories','/admin/vouchers','/admin/staff','/admin/reports','/staff/inventory','/admin/products','/admin/users']){const html=await page(admin,url);ok(!html.includes('HTTP Status 500'), 'render '+url);ok(!/Ã|Ä|áº|á»|Â/.test(html),'Vietnamese encoding '+url);}
 for(const [ctx,url,status] of [[store,'/admin/staff',403],[store,'/delivery/orders',403],[driver,'/staff/orders',403],[driver,'/admin/fulfillment',403],[driver,'/delivery/orders?id=1',404],[customer,'/admin/reports',403],[admin,'/views/admin/dashboard.jsp',404]]){const r=await ctx.get(baseURL+url,{maxRedirects:0});ok(r.status()===status,'authorization '+url+' -> '+status);}
 await page(store,'/staff/orders');await page(driver,'/delivery/orders');await page(customer,'/order-detail?id=2');
 ok(!(await page(other,'/order-detail?id=2')).includes('Khách kiểm thử'),'customer cannot read another account order');
 ok((await admin.post(baseURL+'/admin/categories',{form:{action:'save',name:'Forbidden',slug:'forbidden'},maxRedirects:0})).status()===403,'missing CSRF rejected');
 ok((await admin.post(baseURL+'/admin/orders',{form:{csrfToken:token(await page(admin,'/admin/categories')),orderId:'2',orderStatus:'cancelled'},maxRedirects:0})).status()===405,'legacy arbitrary status mutation removed');
 let html=await page(admin,'/admin/categories'),csrf=token(html);const unique=Date.now().toString();
 const createdProduct=await admin.post(baseURL+'/admin/products',{multipart:{csrfToken:csrf,action:'create',categoryId:'1',productName:'Bánh multipart '+unique,sku:'MULTI'+unique,slug:'multi-'+unique,price:'50000',quantityInStock:'12',flavor:'Vani',size:'Nhỏ',image:{name:'test.png',mimeType:'image/png',buffer:Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64')}}});
 ok((await createdProduct.text()).includes('Bánh multipart '+unique),'existing multipart product creation works with CSRF filter');
 const productHtml=await page(admin,'/admin/products');const productIndex=productHtml.indexOf('Bánh multipart '+unique);const productRow=productHtml.slice(productHtml.lastIndexOf('<tr',productIndex),productHtml.indexOf('</tr>',productIndex));const newPid=productRow.match(/name="productId" value="(\d+)"/)[1];
 await admin.post(baseURL+'/admin/products',{form:{csrfToken:csrf,action:'toggle-status',productId:newPid,newStatus:'inactive'}});
 ok((await page(admin,'/admin/products?action=edit&id='+newPid)).includes('value="Bánh multipart '+unique+'"'),'admin can edit hidden product');
 html=await (await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'save',id:'0',name:'Danh mục kiểm thử '+unique,slug:'test-'+unique,description:'Mô tả bánh tiếng Việt'}})).text();
 ok(html.includes('Danh mục kiểm thử '+unique) && html.includes('Đã lưu thay đổi'),'create category with Vietnamese text');
 const categoryId=formId(html,'Danh mục kiểm thử '+unique,'categories');
 html=await page(admin,'/admin/categories?edit='+categoryId);ok(html.includes('Mô tả bánh tiếng Việt'),'edit form keeps description');
 await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'toggle',id:categoryId}});
 html=await (await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'delete',id:categoryId}})).text();ok(!html.includes('Danh mục kiểm thử '+unique),'delete unreferenced category');
 html=await (await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'delete',id:'1'}})).text();ok(html.includes('đang có sản phẩm'),'cannot delete referenced category');
 await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'toggle',id:'1'}});
 ok(!(await page(customer,'/products')).includes('Bánh kem dâu'),'hidden category hides products');
 await admin.post(baseURL+'/admin/categories',{form:{csrfToken:csrf,action:'toggle',id:'1'}});
 const voucher={csrfToken:csrf,action:'save',id:'0',code:'HTTP'+unique,name:'Ưu đãi '+unique,discountType:'percent',discountValue:'101',minimum:'0',maximum:'50000',quantity:'5',startDate:'2026-01-01T00:00',endDate:'2027-01-01T00:00'};
 html=await(await admin.post(baseURL+'/admin/vouchers',{form:voucher})).text();ok(html.includes('tối đa là 100'),'reject percent discount over 100');
 voucher.discountValue='10';html=await(await admin.post(baseURL+'/admin/vouchers',{form:voucher})).text();ok(html.includes(voucher.code),'create voucher');const vid=formId(html,voucher.name,'vouchers');
 voucher.id=vid;voucher.expectedQuantity='0';voucher.quantity='9';html=await(await admin.post(baseURL+'/admin/vouchers',{form:voucher})).text();ok(html.includes('Lượt sử dụng vừa thay đổi'),'stale voucher quantity edit rejected');
 voucher.expectedQuantity='5';voucher.quantity='6';await admin.post(baseURL+'/admin/vouchers',{form:voucher});
 html=await page(admin,'/admin/vouchers?edit='+vid);ok(html.includes('name="quantity" type="number" min="0" max="1000000" required value="6"'),'voucher edit persisted');
 await admin.post(baseURL+'/admin/vouchers',{form:{csrfToken:csrf,action:'delete',id:vid}});
 const email='http'+unique+'@ops.test';const staffForm={csrfToken:csrf,action:'save',id:'0',name:'Nhân viên '+unique,email,phone:'0902345678',role:'store_staff',password:'NewStaff123!'};
 html=await(await admin.post(baseURL+'/admin/staff',{form:staffForm})).text();ok(html.includes(email),'create employee through admin form');const sid=formId(html,staffForm.name,'staff');
 const created=await login(email,'NewStaff123!');await page(created,'/staff/orders');
 await admin.post(baseURL+'/admin/staff',{form:{csrfToken:csrf,action:'toggle',id:sid}});
 const blocked=await created.get(baseURL+'/staff/orders',{maxRedirects:0});ok(blocked.status()===302&&blocked.headers().location.includes('/login'),'deactivation revokes existing employee session');
 await admin.post(baseURL+'/admin/staff',{form:{csrfToken:csrf,action:'toggle',id:sid}});
 staffForm.id=sid;staffForm.password='';staffForm.role='delivery_staff';await admin.post(baseURL+'/admin/staff',{form:staffForm});const reassigned=await login(email,'NewStaff123!');await page(reassigned,'/delivery/orders');ok((await reassigned.get(baseURL+'/staff/orders')).status()===403,'role update changes employee permissions');
 const anon=await request.newContext();const ipn=await anon.get(baseURL+'/payments/vnpay/ipn');ok((await ipn.json()).RspCode==='97','unsigned IPN rejected over HTTP');
 // Place an order through the actual storefront, then cancel it using both roles.
 html=await page(customer,'/products');let ct=token(await page(customer,'/product-detail?id=2'));
 await customer.post(baseURL+'/add-to-cart',{form:{csrfToken:ct,id:'2',quantity:'1'}});
 html=await page(customer,'/checkout');ok(html.includes('VNPAY Sandbox'),'configured sandbox appears at checkout');
 const orderRes=await customer.post(baseURL+'/place-order',{form:{csrfToken:token(html),recipientName:'Khách HTTP',recipientPhone:'0901234567',shippingAddress:'',receiveMethod:'pickup',paymentMethod:'COD',note:'Kiểm tra nhận tại cửa hàng'},maxRedirects:0});
 ok(orderRes.status()===302&&orderRes.headers().location.includes('/order-success?id='),'pickup checkout accepts no shipping address');const oid=orderRes.headers().location.match(/id=(\d+)/)[1];
 html=await page(customer,'/order-detail?id='+oid);ok(html.includes('Yêu cầu hủy đơn hàng'),'customer cancellation form rendered');
 html=await(await customer.post(baseURL+'/cancel-order',{form:{csrfToken:token(html),orderId:oid,note:'Đổi lịch nhận bánh'}})).text();ok(html.includes('Chờ duyệt hủy'),'customer cancellation request persists');
 html=await page(admin,'/admin/fulfillment?id='+oid);ok(html.includes('Đổi lịch nhận bánh'),'admin sees customer cancellation reason');
 html=await(await admin.post(baseURL+'/admin/fulfillment',{form:{csrfToken:token(html),orderId:oid,action:'transition',target:'cancelled',note:'Đã đồng ý hủy'}})).text();ok(html.includes('Đã duyệt hủy'),'admin approves customer cancellation');
 // Independent HMAC implementation exercises the public read-only return endpoint.
 ct=token(await page(customer,'/product-detail?id=2'));await customer.post(baseURL+'/add-to-cart',{form:{csrfToken:ct,id:'2',quantity:'1'}});html=await page(customer,'/checkout');
 const online=await customer.post(baseURL+'/place-order',{form:{csrfToken:token(html),recipientName:'Khách VNPAY HTTP',recipientPhone:'0901234567',shippingAddress:'Hà Nội',receiveMethod:'delivery',paymentMethod:'VNPAY'},maxRedirects:0});const onlineId=online.headers().location.match(/id=(\d+)/)[1];html=await page(customer,'/order-detail?id='+onlineId);
 const start=await customer.post(baseURL+'/payments/start',{form:{csrfToken:token(html),orderId:onlineId},maxRedirects:0});ok(start.status()===302&&start.headers().location.startsWith('https://sandbox.vnpayment.vn/'),'payment start redirects to sandbox');
 const params=new URL(start.headers().location).searchParams;const transactionNo='2'+unique;const cb={vnp_TmnCode:'TESTONLY',vnp_TxnRef:params.get('vnp_TxnRef'),vnp_Amount:params.get('vnp_Amount'),vnp_ResponseCode:'00',vnp_TransactionStatus:'00',vnp_TransactionNo:transactionNo};
 const sorted=new URLSearchParams(Object.entries(cb).sort(([a],[b])=>a.localeCompare(b))).toString();cb.vnp_SecureHash=crypto.createHmac('sha512','isolated-test-signing-key-not-a-merchant-credential').update(sorted).digest('hex');
 html=await(await customer.get(baseURL+'/payments/vnpay/return?'+new URLSearchParams(cb))).text();ok(html.includes('Thanh toán qua VNPAY Sandbox')&&!html.includes(transactionNo),'browser return does not mark payment paid');
 ok((await(await anon.get(baseURL+'/payments/vnpay/ipn?'+new URLSearchParams(cb))).json()).RspCode==='00','signed IPN updates over HTTP');html=await page(customer,'/order-detail?id='+onlineId);ok(html.includes(transactionNo)&&!html.includes('Thanh toán qua VNPAY Sandbox'),'IPN result visible to customer');
 const browsers=['C:/Program Files/Google/Chrome/Application/chrome.exe','C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe','C:/Program Files/Microsoft/Edge/Application/msedge.exe'];
 const executablePath=browsers.find(fs.existsSync);const browser=await chromium.launch({headless:true,...(executablePath?{executablePath}:{})});
 try{const context=await browser.newContext({storageState:await admin.storageState(),viewport:{width:1440,height:1000}});const tab=await context.newPage();let browserErrors=[];tab.on('pageerror',e=>browserErrors.push(e.message));
 for(const [url,name]of [['/admin/fulfillment?id=2#order-detail','orders'],['/admin/staff','staff'],['/admin/vouchers','vouchers'],['/admin/reports','reports']]){await tab.goto(baseURL+url);await tab.screenshot({path:'.tools/'+name+'-desktop.png',fullPage:true});ok(await tab.locator('h1').count()===1,'browser layout '+name);}
 await tab.setViewportSize({width:390,height:844});await tab.goto(baseURL+'/admin/fulfillment?id=2');await tab.screenshot({path:'.tools/orders-mobile.png',fullPage:true});ok(await tab.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1),'mobile page has no horizontal overflow');ok(browserErrors.length===0,'no browser script errors');
 }finally{await browser.close();}
 for(const ctx of [admin,store,driver,customer,other,created,reassigned,anon])await ctx.dispose();
 console.log('ALL '+count+' HTTP/BROWSER CHECKS PASSED');
}
main().catch(e=>{console.error(e);process.exit(1);});
