package com.constructiondashboard.model;

import java.util.Date;

public class Project {

	String projectid, projectname, pmname, fundsource, projectphase, location, address, latlng;
	
	public String getPmname() {
		return pmname;
	}

	public void setPmname(String pmname) {
		this.pmname = pmname;
	}

	double fars, etpc;
	
	Date projectstart, beneficialocc;
	
	public Project() { super(); }
	
	public Project(String projectid, String projectname, String pmname, String fundsource, String projectphase, String location, 
			double fars, double etpc, Date projectstart, Date beneficialocc,
			String address, String latlng) {
		super();
		
		this.projectid = projectid;
		this.pmname = pmname;
		this.projectname = projectname;
		this.fundsource = fundsource;
		this.projectphase = projectphase;
		this.location = location;
		this.address = address;
		this.latlng = latlng;
		
		this.fars = fars;
		this.etpc = etpc;
		
		this.beneficialocc = beneficialocc;
		this.projectstart = projectstart;
	}

	public String getProjectid() {
		return projectid;
	}

	public void setProjectid(String projectid) {
		this.projectid = projectid;
	}

	public String getProjectname() {
		return projectname;
	}

	public void setProjectname(String projectname) {
		this.projectname = projectname;
	}

	public String getFundsource() {
		return fundsource;
	}

	public void setFundsource(String fundsource) {
		this.fundsource = fundsource;
	}

	public String getProjectphase() {
		return projectphase;
	}

	public void setProjectphase(String projectphase) {
		this.projectphase = projectphase;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getLatlng() {
		return latlng;
	}

	public void setLatlng(String latlng) {
		this.latlng = latlng;
	}

	public double getFars() {
		return fars;
	}

	public void setFars(double fars) {
		this.fars = fars;
	}

	public double getEtpc() {
		return etpc;
	}

	public void setEtpc(double etpc) {
		this.etpc = etpc;
	}

	public Date getProjectstart() {
		return projectstart;
	}

	public void setProjectstart(Date projectstart) {
		this.projectstart = projectstart;
	}

	public Date getBeneficialocc() {
		return beneficialocc;
	}

	public void setBeneficialocc(Date beneficialocc) {
		this.beneficialocc = beneficialocc;
	}
	
	
	
}
