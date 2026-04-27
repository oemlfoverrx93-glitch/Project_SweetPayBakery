package com.sweetpay.controller;

import com.sweetpay.dao.ProductDAO;
import com.sweetpay.model.Category;
import com.sweetpay.model.Product;
import com.sweetpay.util.DBContext;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminProductServlet extends HttpServlet {

    private static final String VIEW_PATH = "/views/admin/manage-products.jsp";
    private static final String STATUS_ALL = "all";
    private static final String STATUS_ACTIVE = "active";
    private static final String STATUS_INACTIVE = "inactive";

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = trimToEmpty(request.getParameter("action")).toLowerCase(Locale.ROOT);
        
        // Handle edit action to load product details
        if ("edit".equals(action)) {
            int productId = parseInt(request.getParameter("id"), -1);
            if (productId > 0) {
                Product editProduct = productDAO.getProductById(productId);
                request.setAttribute("editProduct", editProduct);
            }
        }
        
        String keyword = trimToEmpty(request.getParameter("q"));
        String status = normalizeStatusFilter(request.getParameter("status"));

        List<Product> products = productDAO.getAllForAdmin(keyword, status);
        List<Category> categories = productDAO.getActiveCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = trimToEmpty(request.getParameter("action")).toLowerCase(Locale.ROOT);

        if ("toggle-status".equals(action)) {
            handleToggleStatus(request, response);
            return;
        }
        if ("create".equals(action)) {
            handleCreateProduct(request, response);
            return;
        }
        if ("update".equals(action)) {
            handleUpdateProduct(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/products?error=unsupported-action");
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int productId = parseInt(request.getParameter("productId"), -1);
        String nextStatusRaw = trimToEmpty(request.getParameter("newStatus")).toLowerCase(Locale.ROOT);
        boolean nextStatus = STATUS_ACTIVE.equals(nextStatusRaw);
        boolean updated = productDAO.updateProductStatus(productId, nextStatus);

        String redirect = request.getContextPath() + "/admin/products?updated=" + (updated ? "1" : "0")
                + "&status=" + encode(normalizeStatusFilter(request.getParameter("statusFilter")))
                + "&q=" + encode(trimToEmpty(request.getParameter("q")));
        response.sendRedirect(redirect);
    }

    private void handleCreateProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int categoryId = parseInt(request.getParameter("categoryId"), -1);
        String productName = trimToEmpty(request.getParameter("productName"));
        String sku = trimToEmpty(request.getParameter("sku"));
        String slug = trimToEmpty(request.getParameter("slug"));
        String description = trimToEmpty(request.getParameter("description"));
        String flavor = trimToEmpty(request.getParameter("flavor"));
        String size = trimToEmpty(request.getParameter("size"));
        int quantityInStock = parseInt(request.getParameter("quantityInStock"), -1);

        BigDecimal price = parseMoney(request.getParameter("price"));
        BigDecimal salePrice = parseOptionalMoney(request.getParameter("salePrice"));

        if (categoryId <= 0 || productName.isEmpty() || price == null || price.compareTo(BigDecimal.ZERO) < 0 || quantityInStock < 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-input");
            return;
        }

        if (salePrice != null && salePrice.compareTo(BigDecimal.ZERO) < 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-sale-price");
            return;
        }

        if (salePrice != null && salePrice.compareTo(price) > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=sale-gt-price");
            return;
        }

        if (slug.isEmpty()) {
            slug = slugify(productName);
        } else {
            slug = slugify(slug);
        }
        if (slug.isEmpty()) {
            slug = "product-" + System.currentTimeMillis();
        }

        if (sku.isEmpty()) {
            sku = "SP" + System.currentTimeMillis();
        }

        if (productDAO.existsSku(sku)) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=duplicate-sku");
            return;
        }

        if (productDAO.existsSlug(slug)) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=duplicate-slug");
            return;
        }

        Part imagePart;
        try {
            imagePart = request.getPart("image");
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=image-required");
            return;
        }
        if (imagePart == null || imagePart.getSize() <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=image-required");
            return;
        }

        SavedImage savedImage;
        try {
            savedImage = saveUploadedImage(request, imagePart, slug);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-image-format");
            return;
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/products?error=image-upload-failed");
            return;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Product product = new Product();
            product.setCategoryId(categoryId);
            product.setProductName(productName);
            product.setSku(sku);
            product.setSlug(slug);
            product.setDescription(description.isEmpty() ? null : description);
            product.setPrice(price);
            product.setSalePrice(salePrice);
            product.setFlavor(flavor.isEmpty() ? null : flavor);
            product.setSize(size.isEmpty() ? null : size);
            product.setStatus(true);

            int productId = productDAO.insertProduct(conn, product);
            if (productId <= 0) {
                throw new IllegalStateException("Cannot insert product");
            }

            boolean imageInserted = productDAO.insertMainImage(conn, productId, savedImage.getRelativeUrl());
            if (!imageInserted) {
                throw new IllegalStateException("Cannot insert product image");
            }

            boolean inventoryInserted = productDAO.insertInventory(conn, productId, quantityInStock);
            if (!inventoryInserted) {
                throw new IllegalStateException("Cannot insert inventory");
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/admin/products?created=1");
        } catch (Exception ex) {
            ex.printStackTrace();
            rollbackQuietly(conn);
            deleteQuietly(savedImage.getAbsolutePath());
            response.sendRedirect(request.getContextPath() + "/admin/products?error=create-failed");
        } finally {
            closeQuietly(conn);
        }
    }

    private void handleUpdateProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int productId = parseInt(request.getParameter("productId"), -1);
        if (productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-input");
            return;
        }

        int categoryId = parseInt(request.getParameter("categoryId"), -1);
        String productName = trimToEmpty(request.getParameter("productName"));
        String sku = trimToEmpty(request.getParameter("sku"));
        String slug = trimToEmpty(request.getParameter("slug"));
        String description = trimToEmpty(request.getParameter("description"));
        String flavor = trimToEmpty(request.getParameter("flavor"));
        String size = trimToEmpty(request.getParameter("size"));
        int quantityInStock = parseInt(request.getParameter("quantityInStock"), -1);
        BigDecimal price = parseMoney(request.getParameter("price"));
        BigDecimal salePrice = parseOptionalMoney(request.getParameter("salePrice"));

        if (categoryId <= 0 || productName.isEmpty() || price == null || price.compareTo(BigDecimal.ZERO) < 0 || quantityInStock < 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-input");
            return;
        }

        if (salePrice != null && salePrice.compareTo(BigDecimal.ZERO) < 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-sale-price");
            return;
        }

        if (salePrice != null && salePrice.compareTo(price) > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=sale-gt-price");
            return;
        }

        String oldImage = trimToEmpty(request.getParameter("oldImage"));
        String image = oldImage;

        Part imagePart = null;
        try {
            imagePart = request.getPart("image");
        } catch (Exception ex) {
            // Image part is optional for update
        }

        SavedImage savedImage = null;
        if (imagePart != null && imagePart.getSize() > 0) {
            try {
                String slugForImage = slug.isEmpty() ? slugify(productName) : slug;
                if (slugForImage.isEmpty()) {
                    slugForImage = "product-" + System.currentTimeMillis();
                }
                savedImage = saveUploadedImage(request, imagePart, slugForImage);
                image = savedImage.getRelativeUrl();
            } catch (IllegalArgumentException ex) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=invalid-image-format");
                return;
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/products?error=image-upload-failed");
                return;
            }
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Product product = new Product();
            product.setProductId(productId);
            product.setCategoryId(categoryId);
            product.setProductName(productName);
            product.setSku(sku);
            product.setSlug(slug);
            product.setDescription(description.isEmpty() ? null : description);
            product.setPrice(price);
            product.setSalePrice(salePrice);
            product.setFlavor(flavor.isEmpty() ? null : flavor);
            product.setSize(size.isEmpty() ? null : size);

            boolean productUpdated = productDAO.updateProduct(conn, product);
            if (!productUpdated) {
                throw new IllegalStateException("Cannot update product");
            }

            boolean inventoryUpdated = productDAO.updateInventory(conn, productId, quantityInStock);
            if (!inventoryUpdated) {
                throw new IllegalStateException("Cannot update inventory");
            }

            if (savedImage != null) {
                boolean imageUpdated = productDAO.updateMainImage(conn, productId, image);
                if (!imageUpdated) {
                    throw new IllegalStateException("Cannot update product image");
                }
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/admin/products?updated=1");
        } catch (Exception ex) {
            ex.printStackTrace();
            rollbackQuietly(conn);
            if (savedImage != null) {
                deleteQuietly(savedImage.getAbsolutePath());
            }
            response.sendRedirect(request.getContextPath() + "/admin/products?error=create-failed");
        } finally {
            closeQuietly(conn);
        }
    }

    private SavedImage saveUploadedImage(HttpServletRequest request, Part imagePart, String slug) throws IOException {
        String submittedFileName = imagePart.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing filename");
        }

        String safeName = Paths.get(submittedFileName).getFileName().toString();
        int dotIndex = safeName.lastIndexOf('.');
        if (dotIndex < 0) {
            throw new IllegalArgumentException("Missing extension");
        }

        String extension = safeName.substring(dotIndex).toLowerCase(Locale.ROOT);
        if (!isAllowedExtension(extension)) {
            throw new IllegalArgumentException("Unsupported extension");
        }

        String finalFileName = slug + "-" + UUID.randomUUID().toString().substring(0, 8) + extension;
        Path uploadDir = resolveUploadDirectory(request);
        Files.createDirectories(uploadDir);

        Path outputPath = uploadDir.resolve(finalFileName);
        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, outputPath, StandardCopyOption.REPLACE_EXISTING);
        }

        String relativeUrl = "assets/images/products/" + finalFileName;
        return new SavedImage(relativeUrl, outputPath);
    }

    private Path resolveUploadDirectory(HttpServletRequest request) {
        String realPath = request.getServletContext().getRealPath("/assets/images/products");
        if (realPath != null && !realPath.trim().isEmpty()) {
            return Paths.get(realPath);
        }

        return Paths.get(System.getProperty("user.dir"), "web", "assets", "images", "products");
    }

    private boolean isAllowedExtension(String extension) {
        return ".jpg".equals(extension)
                || ".jpeg".equals(extension)
                || ".png".equals(extension)
                || ".webp".equals(extension)
                || ".gif".equals(extension);
    }

    private BigDecimal parseMoney(String raw) {
        String value = trimToEmpty(raw);
        if (value.isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private BigDecimal parseOptionalMoney(String raw) {
        String value = trimToEmpty(raw);
        if (value.isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private int parseInt(String raw, int fallbackValue) {
        try {
            return Integer.parseInt(trimToEmpty(raw));
        } catch (NumberFormatException ex) {
            return fallbackValue;
        }
    }

    private String normalizeStatusFilter(String rawStatus) {
        String normalized = trimToEmpty(rawStatus).toLowerCase(Locale.ROOT);
        if (STATUS_ACTIVE.equals(normalized) || STATUS_INACTIVE.equals(normalized)) {
            return normalized;
        }
        return STATUS_ALL;
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private String slugify(String value) {
        String text = trimToEmpty(value).toLowerCase(Locale.ROOT);
        if (text.isEmpty()) {
            return "";
        }

        String normalized = Normalizer.normalize(text, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .replace('\u0111', 'd');

        normalized = normalized.replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+", "")
                .replaceAll("-+$", "");
        return normalized;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        try {
            conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void deleteQuietly(Path path) {
        if (path == null) {
            return;
        }
        try {
            Files.deleteIfExists(path);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    private static class SavedImage {
        private final String relativeUrl;
        private final Path absolutePath;

        SavedImage(String relativeUrl, Path absolutePath) {
            this.relativeUrl = relativeUrl;
            this.absolutePath = absolutePath;
        }

        String getRelativeUrl() {
            return relativeUrl;
        }

        Path getAbsolutePath() {
            return absolutePath;
        }
    }
}
