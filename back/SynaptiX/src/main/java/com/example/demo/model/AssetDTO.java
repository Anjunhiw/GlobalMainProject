package com.example.demo.model;

public class AssetDTO {
    private Long totalAssets;
    private Long currentAssets;
    private Long totalEarning;
    private Long totalCost;

    public AssetDTO() {}

    public AssetDTO(Long totalAssets, Long currentAssets, Long totalEarning, Long totalCost) {
        this.totalAssets = totalAssets;
        this.currentAssets = currentAssets;
        this.totalEarning = totalEarning;
        this.totalCost = totalCost;
    }

    public Long getTotalAssets() {
        return totalAssets;
    }

    public void setTotalAssets(Long totalAssets) {
        this.totalAssets = totalAssets;
    }

    public Long getCurrentAssets() {
        return currentAssets;
    }

    public void setCurrentAssets(Long currentAssets) {
        this.currentAssets = currentAssets;
    }

    public Long getTotalEarning() {
        return totalEarning;
    }

    public void setTotalEarning(Long totalEarning) {
        this.totalEarning = totalEarning;
    }

    public Long getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(Long totalCost) {
        this.totalCost = totalCost;
    }
}