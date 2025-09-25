package com.example.demo.model;

public class MPSDTO {

	private int pk;
	private int ProductId;
	private String Period;
	private Float Volume;
	private String productName;
	private Float price;
	
	public MPSDTO() {}
	
	public MPSDTO(int pk, int productId, String period, Float volume) {
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
	
	public String getPeriod() {
		return Period;
	}
	
	public void setPeriod(String period) {
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

	public Float getPrice() {
		return price;
	}

	public void setPrice(Float price) {
		this.price = price;
	}
}