package com.example.demo.model;

public class QCDTO {

	private int mpsId;
	private boolean passed;
	
	private int code;
	private String name;
	private String model;
	private String specification;
	private String period;
	
	public QCDTO() {}
	
	public QCDTO(int mpsId, boolean passed) {
		this.mpsId = mpsId;
		this.passed = passed;
	}
	
	//getters and setters
	public int getMpsId() {
		return mpsId;
	}
	
	public void setMpsId(int mpsId) {
		this.mpsId = mpsId;
	}
	
	public boolean isPassed() {
		return passed;
	}
	
	public void setPassed(boolean passed) {
		this.passed = passed;
	}

	public int getCode() { return code; }
	public void setCode(int code) { this.code = code; }
	public String getName() { return name; }
	public void setName(String name) { this.name = name; }
	public String getModel() { return model; }
	public void setModel(String model) { this.model = model; }
	public String getSpecification() { return specification; }
	public void setSpecification(String specification) { this.specification = specification; }
	public String getPeriod() { return period; }
	public void setPeriod(String period) { this.period = period; }
}