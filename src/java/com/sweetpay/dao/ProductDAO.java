package com.sweetpay.dao;

import com.sweetpay.model.Category;
import com.sweetpay.model.Product;
import com.sweetpay.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    private static final String BASE_SELECT =
            "SELECT p.product_id, p.category_id, p.product_name, p.sku, p.slug, p.description, "
            + "p.price, p.sale_price, p.flavor, p.size, p.status, p.created_at, "
            + "pi.image_url AS main_image, inv.quantity_in_stock "
            + "FROM products p "
            + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
            + "LEFT JOIN inventory inv ON inv.product_id = p.product_id "
            + "WHERE p.status = 1 ";

    private static final String ADMIN_SELECT_NO_STOCK =
            "SELECT p.product_id, p.category_id, c.category_name, p.product_name, p.sku, p.slug, p.description, "
            + "p.price, p.sale_price, p.flavor, p.size, p.status, p.created_at, "
            + "pi.image_url AS main_image "
            + "FROM products p "
            + "LEFT JOIN categories c ON p.category_id = c.category_id "
            + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
            + "WHERE 1 = 1 ";

    private static final String ADMIN_SELECT_WITH_STOCK =
            "SELECT p.product_id, p.category_id, c.category_name, p.product_name, p.sku, p.slug, p.description, "
            + "p.price, p.sale_price, p.flavor, p.size, p.status, p.created_at, "
            + "pi.image_url AS main_image, inv.quantity_in_stock "
            + "FROM products p "
            + "LEFT JOIN categories c ON p.category_id = c.category_id "
            + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
            + "LEFT JOIN inventory inv ON inv.product_id = p.product_id "
            + "WHERE 1 = 1 ";

    public List<Product> getAllProducts() {
        String sql = BASE_SELECT + "ORDER BY p.product_id DESC";
        List<Product> list = queryProducts(sql);
        System.out.println("[ProductDAO] getAllProducts fetched: " + list.size());
        return list;
    }

    public Product getProductById(int id) {
        String sql = BASE_SELECT + "AND p.product_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Product> getProductsByCategory(int categoryId) {
        String sql = BASE_SELECT + "AND p.category_id = ? ORDER BY p.product_id DESC";

        List<Product> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> searchProducts(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllProducts();
        }

        String sql = BASE_SELECT
                + "AND (p.product_name LIKE ? OR p.description LIKE ? OR p.flavor LIKE ? OR p.sku LIKE ? OR p.slug LIKE ?) "
                + "ORDER BY p.product_id DESC";

        String value = "%" + keyword.trim() + "%";
        List<Product> list = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) {
                ps.setString(i, value);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> getFeaturedProducts() {
        return getFeaturedProducts(8);
    }

    public List<Product> getFeaturedProducts(int limit) {
        int safeLimit = limit > 0 ? Math.min(limit, 20) : 8;
        String sql = "SELECT TOP " + safeLimit + " p.product_id, p.category_id, p.product_name, p.sku, p.slug, p.description, "
                + "p.price, p.sale_price, p.flavor, p.size, p.status, p.created_at, "
                + "pi.image_url AS main_image, inv.quantity_in_stock "
                + "FROM products p "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
                + "LEFT JOIN inventory inv ON inv.product_id = p.product_id "
                + "WHERE p.status = 1 "
                + "ORDER BY p.created_at DESC, p.product_id DESC";
        return queryProducts(sql);
    }

    public List<Product> getAllForAdmin(String keyword, String statusFilter) {
        String normalizedStatus = normalizeAdminStatusFilter(statusFilter);
        String normalizedKeyword = keyword == null ? "" : keyword.trim();

        List<Product> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection()) {
            StringBuilder sql = new StringBuilder(inventoryTableExists(conn) ? ADMIN_SELECT_WITH_STOCK : ADMIN_SELECT_NO_STOCK);

            if ("active".equals(normalizedStatus)) {
                sql.append("AND p.status = 1 ");
            } else if ("inactive".equals(normalizedStatus)) {
                sql.append("AND p.status = 0 ");
            }

            if (!normalizedKeyword.isEmpty()) {
                sql.append("AND (p.product_name LIKE ? OR p.sku LIKE ? OR p.slug LIKE ? OR c.category_name LIKE ?) ");
            }

            sql.append("ORDER BY p.product_id DESC");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (!normalizedKeyword.isEmpty()) {
                String like = "%" + normalizedKeyword + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Category> getActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, category_name, slug, description, image_url, status "
                + "FROM categories WHERE status = 1 ORDER BY category_name ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("category_id"));
                category.setCategoryName(rs.getString("category_name"));
                category.setSlug(rs.getString("slug"));
                category.setDescription(rs.getString("description"));
                category.setImageUrl(rs.getString("image_url"));
                category.setStatus(rs.getBoolean("status"));
                categories.add(category);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return categories;
    }

    public boolean existsSku(String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM products WHERE sku = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean existsSlug(String slug) {
        if (slug == null || slug.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM products WHERE slug = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int insertProduct(Connection conn, Product product) throws SQLException {
        if (conn == null || product == null) {
            return -1;
        }

        String sql = "INSERT INTO products ("
                + "category_id, product_name, sku, slug, description, "
                + "price, sale_price, flavor, size, status, created_at"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, product.getCategoryId());
            ps.setString(2, product.getProductName());
            setNullableString(ps, 3, product.getSku());
            setNullableString(ps, 4, product.getSlug());
            setNullableString(ps, 5, product.getDescription());
            ps.setBigDecimal(6, defaultMoney(product.getPrice()));
            setNullableBigDecimal(ps, 7, product.getSalePrice());
            setNullableString(ps, 8, product.getFlavor());
            setNullableString(ps, 9, product.getSize());
            ps.setBoolean(10, product.isStatus());

            int affectedRows = ps.executeUpdate();
            if (affectedRows <= 0) {
                return -1;
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }

    public boolean insertMainImage(Connection conn, int productId, String imageUrl) throws SQLException {
        if (conn == null || productId <= 0 || imageUrl == null || imageUrl.trim().isEmpty()) {
            return false;
        }

        String clearMainSql = "UPDATE product_images SET is_main = 0 WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(clearMainSql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }

        String sql = "INSERT INTO product_images (product_id, image_url, is_main, sort_order) VALUES (?, ?, 1, 1)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean insertInventory(Connection conn, int productId, int quantityInStock) throws SQLException {
        if (conn == null || productId <= 0 || quantityInStock < 0) {
            return false;
        }
        if (!inventoryTableExists(conn)) {
            return true;
        }

        String updateSql = "UPDATE inventory SET quantity_in_stock = ?, updated_at = GETDATE() WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, quantityInStock);
            ps.setInt(2, productId);
            int updatedRows = ps.executeUpdate();
            if (updatedRows > 0) {
                return true;
            }
        }

        String insertSql = "INSERT INTO inventory (product_id, quantity_in_stock, updated_at) VALUES (?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, productId);
            ps.setInt(2, quantityInStock);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateProductStatus(int productId, boolean status) {
        if (productId <= 0) {
            return false;
        }

        String sql = "UPDATE products SET status = ? WHERE product_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProduct(Connection conn, Product product) throws SQLException {
        if (conn == null || product == null || product.getProductId() <= 0) {
            return false;
        }

        String sql = "UPDATE products SET "
                + "category_id = ?, "
                + "product_name = ?, "
                + "sku = ?, "
                + "slug = ?, "
                + "description = ?, "
                + "price = ?, "
                + "sale_price = ?, "
                + "flavor = ?, "
                + "size = ? "
                + "WHERE product_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, product.getCategoryId());
            ps.setString(2, product.getProductName());
            setNullableString(ps, 3, product.getSku());
            setNullableString(ps, 4, product.getSlug());
            setNullableString(ps, 5, product.getDescription());
            ps.setBigDecimal(6, defaultMoney(product.getPrice()));
            setNullableBigDecimal(ps, 7, product.getSalePrice());
            setNullableString(ps, 8, product.getFlavor());
            setNullableString(ps, 9, product.getSize());
            ps.setInt(10, product.getProductId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateMainImage(Connection conn, int productId, String imageUrl) throws SQLException {
        if (conn == null || productId <= 0 || imageUrl == null || imageUrl.trim().isEmpty()) {
            return false;
        }

        String clearMainSql = "UPDATE product_images SET is_main = 0 WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(clearMainSql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }

        String sql = "INSERT INTO product_images (product_id, image_url, is_main, sort_order) VALUES (?, ?, 1, 1)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateInventory(Connection conn, int productId, int quantityInStock) throws SQLException {
        if (conn == null || productId <= 0 || quantityInStock < 0) {
            return false;
        }
        if (!inventoryTableExists(conn)) {
            return true;
        }

        String sql = "UPDATE inventory SET quantity_in_stock = ?, updated_at = GETDATE() WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityInStock);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        }
    }

    public Integer getAvailableStock(int productId) {
        String sql = "SELECT quantity_in_stock FROM inventory WHERE product_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity_in_stock");
                }
            }
        } catch (SQLException sqlEx) {
            String message = sqlEx.getMessage();
            if (message != null && message.toLowerCase().contains("invalid object name")) {
                return null;
            }
            sqlEx.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private List<Product> queryProducts(String sql) {
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(getOptionalString(rs, "category_name"));
        p.setProductName(rs.getString("product_name"));
        p.setSku(rs.getString("sku"));
        p.setSlug(rs.getString("slug"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setSalePrice(rs.getBigDecimal("sale_price"));
        p.setFlavor(rs.getString("flavor"));
        p.setSize(rs.getString("size"));
        p.setStatus(rs.getBoolean("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        String imageUrl = rs.getString("main_image");
        p.setMainImage(imageUrl);
        p.setImageUrl(imageUrl);
        p.setQuantityInStock(getOptionalInteger(rs, "quantity_in_stock"));
        return p;
    }

    private String normalizeAdminStatusFilter(String statusFilter) {
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            return "all";
        }
        String value = statusFilter.trim().toLowerCase();
        if ("active".equals(value) || "inactive".equals(value)) {
            return value;
        }
        return "all";
    }

    private boolean inventoryTableExists(Connection conn) {
        String sql = "SELECT OBJECT_ID('dbo.inventory', 'U') AS table_id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getObject("table_id") != null;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ex) {
            return null;
        }
    }

    private Integer getOptionalInteger(ResultSet rs, String columnName) {
        try {
            int value = rs.getInt(columnName);
            return rs.wasNull() ? null : value;
        } catch (SQLException ex) {
            return null;
        }
    }

    private void setNullableString(PreparedStatement ps, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            ps.setNull(index, Types.NVARCHAR);
            return;
        }
        ps.setString(index, value.trim());
    }

    private void setNullableBigDecimal(PreparedStatement ps, int index, BigDecimal value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.DECIMAL);
            return;
        }
        ps.setBigDecimal(index, value);
    }

    private BigDecimal defaultMoney(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}
