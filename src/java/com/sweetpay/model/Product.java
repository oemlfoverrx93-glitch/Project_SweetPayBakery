package com.sweetpay.model;

import java.math.BigDecimal;
import java.util.Date;

public class Product {
    private int productId;
    private int categoryId;
    private String categoryName;
    private String productName;
    private String sku;
    private String slug;
    private String description;
    private BigDecimal price;
    private BigDecimal salePrice;
    private String flavor;
    private String size;
    private boolean status;
    private Date createdAt;
    private String mainImage;
    private Integer quantityInStock;

    public Product() {
    }

    public Product(int productId, int categoryId, String productName, String sku, String slug,
                   String description, BigDecimal price, BigDecimal salePrice,
                   String flavor, String size, boolean status, Date createdAt, String mainImage) {
        this.productId = productId;
        this.categoryId = categoryId;
        this.productName = productName;
        this.sku = sku;
        this.slug = slug;
        this.description = description;
        this.price = price;
        this.salePrice = salePrice;
        this.flavor = flavor;
        this.size = size;
        this.status = status;
        this.createdAt = createdAt;
        this.mainImage = mainImage;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public String getFlavor() {
        return flavor;
    }

    public void setFlavor(String flavor) {
        this.flavor = flavor;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getMainImage() {
        return mainImage;
    }

    public void setMainImage(String mainImage) {
        this.mainImage = mainImage;
    }

    public Integer getQuantityInStock() {
        return quantityInStock;
    }

    public void setQuantityInStock(Integer quantityInStock) {
        this.quantityInStock = quantityInStock;
    }

    // Alias for compatibility with views that use imageUrl naming.
    public String getImageUrl() {
        return mainImage;
    }

    public void setImageUrl(String imageUrl) {
        this.mainImage = imageUrl;
    }
}
