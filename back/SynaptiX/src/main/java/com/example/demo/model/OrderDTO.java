package com.example.demo.model;

public class OrderDTO {
    private int orderNo;
    private java.sql.Date orderDate;
    private int prodCode;
    private String prodName;
    private long qty;
    private float unitPrice;
    private float amount;
    private String status;

    public int getOrderNo() {
        return orderNo;
    }
    public void setOrderNo(int orderNo) {
        this.orderNo = orderNo;
    }

    public java.sql.Date getOrderDate() {
        return orderDate;
    }
    public void setOrderDate(java.sql.Date orderDate) {
        this.orderDate = orderDate;
    }

    public int getProdCode() {
        return prodCode;
    }
    public void setProdCode(int prodCode) {
        this.prodCode = prodCode;
    }

    public String getProdName() {
        return prodName;
    }
    public void setProdName(String prodName) {
        this.prodName = prodName;
    }

    public long getQty() {
        return qty;
    }
    public void setQty(long qty) {
        this.qty = qty;
    }

    public float getUnitPrice() {
        return unitPrice;
    }
    public void setUnitPrice(float unitPrice) {
        this.unitPrice = unitPrice;
    }

    public float getAmount() {
        return amount;
    }
    public void setAmount(float amount) {
        this.amount = amount;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
}