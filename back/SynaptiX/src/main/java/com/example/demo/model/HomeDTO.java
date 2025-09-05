package com.example.demo.model;

public class HomeDTO {
    private int id;
    private String name;

    // 기본 생성자
    public HomeDTO() {}

    // 전체 필드 생성자
    public HomeDTO(int id, String name) {
        this.id = id;
        this.name = name;
    }

    // Getter/Setter
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    

    // toString
    @Override
    public String toString() {
        return "HomeDTO{" +
                "id=" + id +
                ", name='" + name + '\'' +'}';
    }
}