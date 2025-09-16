package com.example.demo.model;

public class Sales {
    private String saleDate;
    private String productId;
    private String productName;
    private int quantity;
    private int amount;

    // Getters and Setters
    public String getSaleDate() { return saleDate; }
    public void setSaleDate(String saleDate) { this.saleDate = saleDate; }
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
}
