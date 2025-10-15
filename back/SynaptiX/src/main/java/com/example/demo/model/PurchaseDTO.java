package com.example.demo.model;

import java.util.Date;
public class PurchaseDTO {

	private int pk;
	private int MaterialId;
	private Integer Cost;
	private Float Purchase;
	private String Date;
	private String materialName;
	
	private int stock; // 구매량
	private int price; // 단가
	private int amount; // 구매금액
	private Date purchaseDate; // 구매일자(매핑용)
	
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
	
	public String getDate() {
		return Date;
	}
	
	public void setDate(String date) {
		Date = date;
	}

	public String getMaterialName() {
		return materialName;
	}

	public void setMaterialName(String materialName) {
		this.materialName = materialName;
	}

	public int getStock() {
		return stock;
	}

	public void setStock(int stock) {
		this.stock = stock;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public int getAmount() {
		return amount;
	}

	public void setAmount(int amount) {
		this.amount = amount;
	}

	public Date getPurchaseDate() {
		return purchaseDate;
	}

	public void setPurchaseDate(Date purchaseDate) {
		this.purchaseDate = purchaseDate;
	}
}