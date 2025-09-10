package com.example.demo.model;

public class MaterialDTO {
    private int pk;
    private String category;
    private String name;
    private String specification;
    private String unit;
    private Integer price;
    private Float stock;
    private Float amount;

    public MaterialDTO() {}

    public MaterialDTO(int pk, String category, String name, String specification, String unit, Integer price, Float stock, Float amount) {
        this.pk = pk;
        this.category = category;
        this.name = name;
        this.specification = specification;
        this.unit = unit;
        this.price = price;
        this.stock = stock;
        this.amount = amount;
    }

    public int getPk() { return pk; }
    public void setPk(int pk) { this.pk = pk; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSpecification() { return specification; }
    public void setSpecification(String specification) { this.specification = specification; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }

    public Float getStock() { return stock; }
    public void setStock(Float stock) { this.stock = stock; }

    public Float getAmount() { return amount; }
    public void setAmount(Float amount) { this.amount = amount; }

    @Override
    public String toString() {
        return "MaterialDTO{" +
                "pk=" + pk +
                ", category='" + category + '\'' +
                ", name='" + name + '\'' +
                ", specification='" + specification + '\'' +
                ", unit='" + unit + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", amount=" + amount +
                '}';
    }
}
