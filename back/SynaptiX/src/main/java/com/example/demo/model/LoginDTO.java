package com.example.demo.model;

public class LoginDTO {

	private int id;
	private int years;
	private long salary;
	private String pw;
	private String name;
	private String email;
	private String dept;
	
	public LoginDTO() {}
	
	public LoginDTO(int id, int years, long salary, String pw, String name, String email, String dept) {
		this.id = id;
		this.years = years;
		this.salary = salary;
		this.pw = pw;
		this.name = name;
		this.email = email;
		this.dept = dept;
	}
	
	
	//getters and setters
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	
	public int getYears() {
		return years;
	}
	public void setYears(int years) {
		this.years = years;
	}
	
	public long getSalary() {
		return salary;
	}
	public void setSalary(long salary) {
		this.salary = salary;
	}
	public String getPw() {
		return pw;
	}
	public void setPw(String pw) {
		this.pw = pw;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getDept() {
		return dept;
	}
	public void setDept(String dept) {
		this.dept = dept;
	}
	
}
