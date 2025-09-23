package com.example.demo.model;

public class BOMDTO {
	
	private int ProductId;
	private int MaterialId;
	private Float MaterialAmount;
	private String productName;
	private String materialName;
	
	public BOMDTO() {}
	
	public BOMDTO(int productId, int materialId, Float materialAmount) {
		this.ProductId = productId;
		this.MaterialId = materialId;
		this.MaterialAmount = materialAmount;
	}
	
	//getters and setters
	public int getProductId() {
		return ProductId;
	}
	public void setProductId(int productId) {
		ProductId = productId;
	}
	
	public int getMaterialId() {
		return MaterialId;
	}
	
	public void setMaterialId(int materialId) {
		MaterialId = materialId;
	}
	
	public Float getMaterialAmount() {
		return MaterialAmount;
	}
	
	public void setMaterialAmount(Float materialAmount) {
		MaterialAmount = materialAmount;
	}

	public String getProductName() { 
		return productName; 
	}
	public void setProductName(String productName) { 
		this.productName = productName; 
	}
	public String getMaterialName() { 
		return materialName; 
	}
	public void setMaterialName(String materialName) { 
		this.materialName = materialName; 
	}
		
}