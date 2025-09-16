package com.example.demo.model;

public class EarnCostDTO {

	private int pk;
	private int EarningId;
	private int CostId;
	
	public EarnCostDTO() {}
	
	public EarnCostDTO(int pk, int earningId, int costId) {
		this.pk = pk;
		this.EarningId = earningId;
		this.CostId = costId;
	}
	
	//getters and setters
	public int getPk() {
		return pk;
	}
	
	public void setPk(int pk) {
		this.pk = pk;
	}
	
	public int getEarningId() {
		return EarningId;
	}
	
	public void setEarningId(int earningId) {
		EarningId = earningId;
	}
	
	public int getCostId() {
		return CostId;
	}
	
	public void setCostId(int costId) {
		CostId = costId;
	}
	
}
