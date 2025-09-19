package com.example.demo.model;

import java.util.Date;

public class MPSDTO {

	private int pk;
	private int ProductId;
	private Date Period;
	private Float Volume;
	private String productName;
	
	public MPSDTO() {}
	
	public MPSDTO(int pk, int productId, Date period, Float volume) {
		this.pk = pk;
		this.ProductId = productId;
		this.Period = period;
		this.Volume = volume;
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
	
	public Date getPeriod() {
		return Period;
	}
	
	public void setPeriod(Date period) {
		Period = period;
	}
	
	public Float getVolume() {
		return Volume;
	}
	
	public void setVolume(Float volume) {
		Volume = volume;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}
}