package com.constructiondashboard.model;

public class Far {
	
	int fundnumber; 
	String fundsource, fundname; 
	double approvedfars, pendingfars;
	
	public Far (int fundnumber, String fundsource, String fundname, double approvedfars, double pendingfars) {
		super();
		this.fundnumber = fundnumber;
		this.fundsource = fundsource;
		this.fundname = fundname;
		this.approvedfars = approvedfars;
		this.pendingfars = pendingfars;
	}

	public int getFundnumber() {
		return fundnumber;
	}

	public void setFundnumber(int fundnumber) {
		this.fundnumber = fundnumber;
	}

	public String getFundsource() {
		return fundsource;
	}

	public void setFundsource(String fundsource) {
		this.fundsource = fundsource;
	}

	public String getFundname() {
		return fundname;
	}

	public void setFundname(String fundname) {
		this.fundname = fundname;
	}

	public double getApprovedfars() {
		return approvedfars;
	}

	public void setApprovedfars(double approvedfars) {
		this.approvedfars = approvedfars;
	}

	public double getPendingfars() {
		return pendingfars;
	}

	public void setPendingfars(double pendingfars) {
		this.pendingfars = pendingfars;
	}

	@Override
	public String toString() {
		return "Far [fundnumber=" + fundnumber + ", fundsource=" + fundsource + ", fundname=" + fundname
				+ ", approvedfars=" + approvedfars + ", pendingfars=" + pendingfars + "]";
	}


}
