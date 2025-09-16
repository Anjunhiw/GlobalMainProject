package com.example.demo.model;

public class QCDTO {

	private int mpsId;
	private boolean passed;
	
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
}