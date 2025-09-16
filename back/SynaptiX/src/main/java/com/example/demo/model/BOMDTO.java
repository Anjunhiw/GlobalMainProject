package com.example.demo.model;

public class BOMDTO {
	
	int ProductId;
	int MaterialId;
	Float MaterialAmount;
	
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
		
}
