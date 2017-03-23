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
public class VendorsSubService {
	@Autowired
	private DataDaoImpl dataDaoImpl;
	
	 public JSONArray getVendorsSub(String username) {
		 return dataDaoImpl.getVendorsSub(username);
	 }

	 public JSONArray getVendorSubDetail(String username, String vendorid) {
		 return dataDaoImpl.getVendorSubDetail(username, vendorid);
	 }

}
