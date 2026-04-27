<%@page import="java.util.List"%>
<%@page import="com.sweetpay.model.Product"%>
<%@page import="com.sweetpay.model.Category"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Products - SweetPay Bakery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #f7f8fc;
        }

        .thumb {
            width: 72px;
            height: 72px;
            object-fit: cover;
            border-radius: 10px;
            border: 1px solid #e9ecef;
            background: #fff;
        }
    </style>
</head>
<body>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (keyword == null) {
        keyword = "";
    }
    if (selectedStatus == null || selectedStatus.trim().isEmpty()) {
        selectedStatus = "all";
    }
%>
<div class="container-fluid py-4 px-3 px-md-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h3 class="mb-0">Quản lý sản phẩm</h3>
        <div class="d-flex gap-2">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-outline-primary">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary">Đơn hàng</a>
            <a href="<%=request.getContextPath()%>/admin/users" class="btn btn-outline-secondary">Khách hàng</a>
            <a href="<%=request.getContextPath()%>/products" class="btn btn-outline-secondary">Trang sản phẩm</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-outline-dark">Đăng xuất</a>
        </div>
    </div>

    <% if ("1".equals(request.getParameter("created"))) { %>
    <div class="alert alert-success">Đã thêm sản phẩm mới thành công.</div>
    <% } %>

    <% if ("1".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-success">Đã cập nhật trạng thái sản phẩm.</div>
    <% } else if ("0".equals(request.getParameter("updated"))) { %>
    <div class="alert alert-danger">Cập nhật trạng thái thất bại.</div>
    <% } %>

    <% String error = request.getParameter("error"); %>
    <% if ("invalid-input".equals(error)) { %>
    <div class="alert alert-warning">Dữ liệu nhập chưa hợp lệ. Vui lòng kiểm tra lại.</div>
    <% } else if ("invalid-sale-price".equals(error)) { %>
    <div class="alert alert-warning">Giá sale phải lớn hơn hoặc bằng 0.</div>
    <% } else if ("sale-gt-price".equals(error)) { %>
    <div class="alert alert-warning">Giá sale không được lớn hơn giá gốc.</div>
    <% } else if ("duplicate-sku".equals(error)) { %>
    <div class="alert alert-warning">SKU đã tồn tại, vui lòng nhập SKU khác.</div>
    <% } else if ("duplicate-slug".equals(error)) { %>
    <div class="alert alert-warning">Slug đã tồn tại, vui lòng nhập slug khác.</div>
    <% } else if ("image-required".equals(error)) { %>
    <div class="alert alert-warning">Vui lòng chọn ảnh sản phẩm trước khi lưu.</div>
    <% } else if ("invalid-image-format".equals(error)) { %>
    <div class="alert alert-warning">Định dạng ảnh không hợp lệ. Chỉ chấp nhận: jpg, jpeg, png, webp, gif.</div>
    <% } else if ("image-upload-failed".equals(error)) { %>
    <div class="alert alert-danger">Upload ảnh thất bại. Vui lòng thử lại.</div>
    <% } else if ("create-failed".equals(error)) { %>
    <div class="alert alert-danger">Thêm sản phẩm thất bại. Hệ thống đã rollback dữ liệu.</div>
    <% } else if ("unsupported-action".equals(error)) { %>
    <div class="alert alert-warning">Hành động không hỗ trợ.</div>
    <% } %>

    <div class="row g-3 mb-3">
        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <%
                        Product editProduct = (Product) request.getAttribute("editProduct");
                    %>
                    <h5 class="card-title mb-3">
                        <%= editProduct != null ? "Cập nhật sản phẩm" : "Thêm sản phẩm mới" %>
                    </h5>
                    <form method="post" action="<%=request.getContextPath()%>/admin/products" enctype="multipart/form-data" class="row g-2">
                        <input type="hidden" name="action" value="<%= editProduct != null ? "update" : "create" %>">
                        <% if (editProduct != null) { %>
                        <input type="hidden" name="productId" value="<%=editProduct.getProductId()%>">
                        <input type="hidden" name="oldImage" value="<%=editProduct.getMainImage() != null ? editProduct.getMainImage() : ""%>">
                        <% } %>

                        <div class="col-12">
                            <label class="form-label">Tên bánh</label>
                            <input type="text" name="productName" class="form-control" required maxlength="150" 
                                   value="<%= editProduct != null ? (editProduct.getProductName() != null ? editProduct.getProductName() : "") : "" %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label">Danh mục</label>
                            <select name="categoryId" class="form-select" required>
                                <option value="">-- Chọn danh mục --</option>
                                <% if (categories != null) {
                                       for (Category category : categories) { 
                                           boolean isSelected = editProduct != null && editProduct.getCategoryId() == category.getCategoryId();
                                   %>
                                <option value="<%=category.getCategoryId()%>" <%= isSelected ? "selected" : "" %>><%=category.getCategoryName()%></option>
                                <%     }
                                   } %>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">SKU</label>
                            <input type="text" name="sku" class="form-control" maxlength="50" placeholder="VD: SP999"
                                   value="<%= editProduct != null ? (editProduct.getSku() != null ? editProduct.getSku() : "") : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Slug</label>
                            <input type="text" name="slug" class="form-control" maxlength="150" placeholder="tu-dong-neu-de-trong"
                                   value="<%= editProduct != null ? (editProduct.getSlug() != null ? editProduct.getSlug() : "") : "" %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label">Mô tả</label>
                            <textarea name="description" rows="2" class="form-control"><%= editProduct != null ? (editProduct.getDescription() != null ? editProduct.getDescription() : "") : "" %></textarea>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Giá gốc</label>
                            <input type="number" name="price" class="form-control" min="0" step="1000" required
                                   value="<%= editProduct != null ? (editProduct.getPrice() != null ? editProduct.getPrice() : "") : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Giá sale</label>
                            <input type="number" name="salePrice" class="form-control" min="0" step="1000"
                                   value="<%= editProduct != null ? (editProduct.getSalePrice() != null ? editProduct.getSalePrice() : "") : "" %>">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Hương vị</label>
                            <input type="text" name="flavor" class="form-control" maxlength="100"
                                   value="<%= editProduct != null ? (editProduct.getFlavor() != null ? editProduct.getFlavor() : "") : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Kích thước</label>
                            <input type="text" name="size" class="form-control" maxlength="50"
                                   value="<%= editProduct != null ? (editProduct.getSize() != null ? editProduct.getSize() : "") : "" %>">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Tồn kho</label>
                            <input type="number" name="quantityInStock" class="form-control" min="0" required
                                   value="<%= editProduct != null ? (editProduct.getQuantityInStock() != null ? editProduct.getQuantityInStock() : "") : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Ảnh chính</label>
                            <input type="file" name="image" class="form-control" accept=".jpg,.jpeg,.png,.webp,.gif" 
                                   <%= editProduct == null ? "required" : "" %>>
                            <% if (editProduct != null && editProduct.getMainImage() != null) { %>
                            <small class="text-muted d-block mt-1">Ảnh hiện tại: <%=editProduct.getMainImage()%></small>
                            <% } %>
                        </div>

                        <div class="col-12 d-grid mt-2">
                            <button type="submit" class="btn btn-primary" <%= (categories == null || categories.isEmpty()) ? "disabled" : "" %>>
                                <%= editProduct != null ? "Cập nhật sản phẩm" : "Lưu sản phẩm" %>
                            </button>
                        </div>
                    </form>

                    <% if (categories == null || categories.isEmpty()) { %>
                    <div class="alert alert-warning mt-3 mb-0">
                        Chưa có danh mục hoạt động. Hãy thêm category trong DB trước khi tạo sản phẩm mới.
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                        <h5 class="card-title mb-0">Danh sách sản phẩm</h5>
                        <form method="get" action="<%=request.getContextPath()%>/admin/products" class="row g-2">
                            <div class="col-auto">
                                <input type="text" class="form-control" name="q" value="<%=keyword%>" placeholder="Tên / SKU / slug">
                            </div>
                            <div class="col-auto">
                                <select name="status" class="form-select">
                                    <option value="all" <%= "all".equals(selectedStatus) ? "selected" : "" %>>Tất cả</option>
                                    <option value="active" <%= "active".equals(selectedStatus) ? "selected" : "" %>>Đang bán</option>
                                    <option value="inactive" <%= "inactive".equals(selectedStatus) ? "selected" : "" %>>Đã ẩn</option>
                                </select>
                            </div>
                            <div class="col-auto">
                                <button type="submit" class="btn btn-outline-primary">Lọc</button>
                            </div>
                        </form>
                    </div>

                    <% if (products == null || products.isEmpty()) { %>
                    <div class="alert alert-info mb-0">Không có sản phẩm phù hợp bộ lọc.</div>
                    <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Ảnh</th>
                                <th>Tên</th>
                                <th>Danh mục</th>
                                <th>Giá</th>
                                <th>Tồn kho</th>
                                <th>Trạng thái</th>
                                <th>Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (Product product : products) {
                                   String image = product.getMainImage() != null ? product.getMainImage() : "assets/images/no-image.jpg";
                                   String categoryName = product.getCategoryName() != null ? product.getCategoryName() : "-";
                                   Integer stock = product.getQuantityInStock();
                                   String stockText = stock == null ? "-" : String.valueOf(stock);
                                   boolean active = product.isStatus();
                            %>
                            <tr>
                                <td><%=product.getProductId()%></td>
                                <td>
                                    <img src="<%=request.getContextPath()%>/<%=image%>" class="thumb" alt="<%=product.getProductName()%>">
                                </td>
                                <td>
                                    <div class="fw-semibold"><%=product.getProductName()%></div>
                                    <div class="text-muted small">SKU: <%=product.getSku() != null ? product.getSku() : "-"%></div>
                                </td>
                                <td><%=categoryName%></td>
                                <td>
                                    <div><%=product.getPrice() != null ? String.format("%,.0f", product.getPrice()) : "0"%> VNĐ</div>
                                    <% if (product.getSalePrice() != null) { %>
                                    <div class="text-danger small">Sale: <%=String.format("%,.0f", product.getSalePrice())%> VNĐ</div>
                                    <% } %>
                                </td>
                                <td><%=stockText%></td>
                                <td>
                                    <% if (active) { %>
                                    <span class="badge bg-success">active</span>
                                    <% } else { %>
                                    <span class="badge bg-secondary">inactive</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="<%=request.getContextPath()%>/admin/products?action=edit&id=<%=product.getProductId()%>" 
                                       class="btn btn-sm btn-warning me-1">
                                        Sửa
                                    </a>
                                    <form method="post" action="<%=request.getContextPath()%>/admin/products" class="d-inline">
                                        <input type="hidden" name="action" value="toggle-status">
                                        <input type="hidden" name="productId" value="<%=product.getProductId()%>">
                                        <input type="hidden" name="q" value="<%=keyword%>">
                                        <input type="hidden" name="statusFilter" value="<%=selectedStatus%>">
                                        <% if (active) { %>
                                        <input type="hidden" name="newStatus" value="inactive">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">Ẩn</button>
                                        <% } else { %>
                                        <input type="hidden" name="newStatus" value="active">
                                        <button type="submit" class="btn btn-sm btn-outline-success">Hiện</button>
                                        <% } %>
                                    </form>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>

