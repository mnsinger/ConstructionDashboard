package com.constructiondashboard.service;

import java.sql.SQLException;
import java.util.List;

import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.constructiondashboard.dao.*;
import com.constructiondashboard.model.*;

@Transactional
@Service
public class PmService {
	@Autowired
	private DataDaoImpl dataDaoImpl;
	
	 public JSONArray getPms(String username) {
		 return dataDaoImpl.getPms(username);
	 }

	 public JSONArray getPmDetail(String username, int pmid) {
		 System.out.println("In getPmDetail Service func");
		 return dataDaoImpl.getPmDetail(username, pmid);
	 }

	 /*public JSONArray getPmInfo(String username, String projectid) {
		 return dataDaoImpl.getPmInfo(username, projectid);
	 }*/

	 /*public JSONArray getProjectFarInfoJSON(String username, String projectid) {
		 return dataDaoImpl.getProjectFarInfoJSON(username, projectid);
	 }*/

}
