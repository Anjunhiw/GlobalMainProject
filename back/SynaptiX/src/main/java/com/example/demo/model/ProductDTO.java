package com.example.demo.model;

public class ProductDTO {
    private int pk;
    private String category;
    private String name;
    private String model;
    private String specification;
    private Integer price;
    private Float stock;
    private Float amount;

    public ProductDTO() {}

    public ProductDTO(int pk, String category, String name, String model, String specification, Integer price, Float stock, Float amount) {
        this.pk = pk;
        this.category = category;
        this.name = name;
        this.model = model;
        this.specification = specification;
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

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getSpecification() { return specification; }
    public void setSpecification(String specification) { this.specification = specification; }

    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }

    public Float getStock() { return stock; }
    public void setStock(Float stock) { this.stock = stock; }

    public Float getAmount() { return amount; }
    public void setAmount(Float amount) { this.amount = amount; }

    @Override
    public String toString() {
        return "ProductDTO{" +
                "pk=" + pk +
                ", category='" + category + '\'' +
                ", name='" + name + '\'' +
                ", model='" + model + '\'' +
                ", specification='" + specification + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", amount=" + amount +
                '}';
    }
}
