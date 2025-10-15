package com.example.demo.model;

public class AssetPlanDTO {
    private int pk;
    private String date;
    private int productId;
    private String productName;
    private int price;
    private int amount;

    // getter, setter
    public int getPk() { return pk; }
    public void setPk(int pk) { this.pk = pk; }
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }

    // 예상수익 getter (단가 × 판매량)
    public int getProfit() {
        return price * amount;
    }
}