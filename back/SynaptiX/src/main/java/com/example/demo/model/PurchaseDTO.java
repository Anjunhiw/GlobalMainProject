package com.example.demo.model;

public class PurchaseDTO {

	private int pk;
	private int MaterialId;
	private Integer Cost;
	private Float Purchase;
	
	public PurchaseDTO() {}
	
	public PurchaseDTO(int pk, int materialId, Integer cost, Float purchase) {
		this.pk = pk;
		this.MaterialId = materialId;
		this.Cost = cost;
		this.Purchase = purchase;
	}
	
	//getters and setters
	public int getPk() {
		return pk;
	}
	
	public void setPk(int pk) {
		this.pk = pk;
	}
	
	public int getMaterialId() {
		return MaterialId;
	}
	
	public void setMaterialId(int materialId) {
		MaterialId = materialId;
	}
	
	public Integer getCost() {
		return Cost;
	}
	
	public void setCost(Integer cost) {
		Cost = cost;
	}
	
	public Float getPurchase() {
		return Purchase;
	}
	
	public void setPurchase(Float purchase) {
		Purchase = purchase;
	}
}
