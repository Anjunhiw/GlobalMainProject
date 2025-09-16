package com.example.demo.model;

import java.util.Date;

public class TransactionDTO {

	private int pk;
	private int ProductId;
	private Integer Earning;
	private Date Date;
	private Float Sales;
	
	public TransactionDTO() {}
	
	public TransactionDTO(int pk, int productId, Integer earning, Date date, Float sales) {
		this.pk = pk;
		this.ProductId = productId;
		this.Earning = earning;
		this.Date = date;
		this.Sales = sales;
	}
	
	//getters and setters
	public int getPk() {
		return pk;
	}
	
	public void setPk(int pk) {
		this.pk = pk;
	}
	
	public int getProductId() {
		return ProductId;
	}
	
	public void setProductId(int productId) {
		ProductId = productId;
	}
	
	public Integer getEarning() {
		return Earning;
	}
	
	public void setEarning(Integer earning) {
		Earning = earning;
	}
	
	public Date getDate() {
		return Date;
	}
	
	public void setDate(Date date) {
		Date = date;
	}
	
	public Float getSales() {
		return Sales;
	}
	
	public void setSales(Float sales) {
		Sales = sales;
	}
}
