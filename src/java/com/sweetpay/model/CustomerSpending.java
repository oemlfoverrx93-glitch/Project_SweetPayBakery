package com.sweetpay.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class CustomerSpending {

    private int userId;
    private String fullName;
    private String email;
    private String phone;
    private int orderCount;
    private BigDecimal totalSpent;
    private Timestamp firstOrderDate;
    private Timestamp lastOrderDate;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) {
        this.orderCount = orderCount;
    }

    public BigDecimal getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(BigDecimal totalSpent) {
        this.totalSpent = totalSpent;
    }

    public Timestamp getFirstOrderDate() {
        return firstOrderDate;
    }

    public void setFirstOrderDate(Timestamp firstOrderDate) {
        this.firstOrderDate = firstOrderDate;
    }

    public Timestamp getLastOrderDate() {
        return lastOrderDate;
    }

    public void setLastOrderDate(Timestamp lastOrderDate) {
        this.lastOrderDate = lastOrderDate;
    }
}
