package com.sweetpay.model;

public class Category {
    private int categoryId;
    private String categoryName;
    private String slug;
    private String description;
    private String imageUrl;
    private boolean status;

    public Category() {
    }

    public Category(int categoryId, String categoryName, String slug, String description, String imageUrl, boolean status) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.slug = slug;
        this.description = description;
        this.imageUrl = imageUrl;
        this.status = status;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
}