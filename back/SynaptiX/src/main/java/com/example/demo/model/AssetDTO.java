package com.example.demo.model;

public class AssetDTO {
	private Integer TotalAssets;
	private Integer CurrentAssets;
	
	public AssetDTO() {}
	
	public AssetDTO(Integer totalAssets, Integer currentAssets) {
		this.TotalAssets = totalAssets;
		this.CurrentAssets = currentAssets;
	}
	
	//getters and setters
	public Integer getTotalAssets() {
		return TotalAssets;
	}
	
	public void setTotalAssets(Integer totalAssets) {
		this.TotalAssets = totalAssets;
	}
	
	public Integer getCurrentAssets() {
		return CurrentAssets;
	}
	
	public void setCurrentAssets(Integer currentAssets) {
		this.CurrentAssets = currentAssets;
	}
}
