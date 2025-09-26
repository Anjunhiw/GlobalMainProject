package com.example.demo.model;

import java.util.Date;

public class TransactionDTO {

	private int pk;
	private int productId;
	private Integer earning;
	private Date date;
	private Float sales;
	private String prodName;
	private Double unitPrice;
	private Double amount;
	
	public TransactionDTO() {}
	
	public TransactionDTO(int pk, int productId, Integer earning, Date date, Float sales, String prodName, Double unitPrice, Double amount) {
		this.pk = pk;
		this.productId = productId;
		this.earning = earning;
		this.date = date;
		this.sales = sales;
		this.prodName = prodName;
		this.unitPrice = unitPrice;
		this.amount = amount;
	}
	
	//getters and setters
	public int getPk() {
		return pk;
	}
	
	public void setPk(int pk) {
		this.pk = pk;
	}
	
	public int getProductId() {
		return productId;
	}
	
	public void setProductId(int productId) {
		this.productId = productId;
	}
	
	public Integer getEarning() {
		return earning;
	}
	
	public void setEarning(Integer earning) {
		this.earning = earning;
	}
	
	public Date getDate() {
		return date;
	}
	
	public void setDate(Date date) {
		this.date = date;
	}
	
	public Float getSales() {
		return sales;
	}
	
	public void setSales(Float sales) {
		this.sales = sales;
	}

	public String getProdName() { return prodName; }
	public void setProdName(String prodName) { this.prodName = prodName; }
	public Double getUnitPrice() { return unitPrice; }
	public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
	public Double getAmount() { return amount; }
	public void setAmount(Double amount) { this.amount = amount; }
}