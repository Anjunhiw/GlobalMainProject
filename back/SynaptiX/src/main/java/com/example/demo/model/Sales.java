package com.example.demo.model;

import java.util.Date;

public class Sales {
    private java.util.Date saleDate;
    private String productId;
    private String productName;
    private int quantity;
    private int amount;
    private int pk;
    private int earning;
    private int price;

    // Getters and Setters
    public Date getSaleDate() { return saleDate; }
    public void setSaleDate(Date saleDate) { this.saleDate = saleDate; }
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public int getPk() { return pk; }
    public void setPk(int pk) { this.pk = pk; }
    public int getEarning() { return earning; }
    public void setEarning(int earning) { this.earning = earning; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
}