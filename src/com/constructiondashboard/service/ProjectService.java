package com.constructiondashboard.service;

import java.sql.SQLException;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.constructiondashboard.dao.*;
import com.constructiondashboard.model.*;

@Transactional
@Service
public class ProjectService {
	@Autowired
	private DataDaoImpl dataDaoImpl;
	
	 public JSONArray getProjects(String username) {
		 return dataDaoImpl.getProjects(username);
	 }

	 public Project getProjectInfo(String username, String projectid) {
		 return dataDaoImpl.getProjectInfo(username, projectid);
	 }

	 public JSONArray getProjectFarInfoJSON(String username, String projectid) {
		 return dataDaoImpl.getProjectFarInfoJSON(username, projectid);
	 }

}
