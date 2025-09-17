package com.example.demo.model;

import java.util.Date;

public class AssetPlanDTO {
    private int pk;
    private Date date;
    private int productId;
    private String productName;
    private int price;
    private int amount;

    // getter, setter
    public int getPk() { return pk; }
    public void setPk(int pk) { this.pk = pk; }
    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
}
