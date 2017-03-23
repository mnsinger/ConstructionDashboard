package com.constructiondashboard.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

import org.json.JSONArray;
import org.json.JSONObject;

import com.constructiondashboard.model.Far;
import com.constructiondashboard.model.Project;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.sql.DataSource;

public class DataDaoImpl implements DataDao {
	
	public DataSource dataSource;

	public void setDataSource(DataSource dataSource) {
		System.out.println("HEEEE " + dataSource.toString());
		this.dataSource = dataSource;
	}
	
	public JSONArray getProjects(String username) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		
		HashMap<String, Integer> phaseMap = new HashMap<String, Integer>();
		HashMap<String, Double> fundSourceMap = new HashMap<String, Double>();
		HashMap<String, Integer> locationMap = new HashMap<String, Integer>();

		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement("select p.projectid, p.projectname, p.fundsource, p.projectphase, p.location, p.etpc, p.projectstart, p.beneficialocc, p.address, p.latlng, pm.name pmname, fars.totalfars from projects p join projectmanagers pm on p.projectmanagerid=pm.id left join (select projectid, IFNULL((sum(approvedfars) + sum(pendingfars)), 0) totalfars from fars group by projectid) fars on p.projectid=fars.projectid order by beneficialocc");
			ResultSet rs = ps.executeQuery();
			
			while (rs.next()) {
				
				JSONObject projJSONObj = new JSONObject();
				
				//System.out.println("username = " + username + " query results = " + rs.getString(1));
				projJSONObj.put("projectid", rs.getString("projectid"));
				projJSONObj.put("projectname", rs.getString("projectname"));
				projJSONObj.put("pmname", rs.getString("pmname"));
				projJSONObj.put("fundsource", rs.getString("fundsource"));
				projJSONObj.put("projectphase", rs.getString("projectphase"));
				projJSONObj.put("location", rs.getString("location"));
				projJSONObj.put("totalfars", rs.getDouble("totalfars"));
				projJSONObj.put("etpc", rs.getDouble("etpc"));
				projJSONObj.put("projectstart", rs.getDate("projectstart"));
				projJSONObj.put("beneficialocc", rs.getDate("beneficialocc"));
				projJSONObj.put("address", rs.getString("address"));
				projJSONObj.put("latlng", rs.getString("latlng"));
						
				arrayJSON.put(projJSONObj);
				
				int count = phaseMap.containsKey(rs.getString("projectphase")) ? phaseMap.get(rs.getString("projectphase")) : 0;
				phaseMap.put(rs.getString("projectphase"), count + 1);
				
				double sum = fundSourceMap.containsKey(rs.getString("fundsource")) ? fundSourceMap.get(rs.getString("fundsource")) : 0;
				fundSourceMap.put(rs.getString("fundsource"), sum + rs.getDouble("totalfars"));
				
				count = locationMap.containsKey(rs.getString("location")) ? locationMap.get(rs.getString("location")) : 0;
				locationMap.put(rs.getString("location"), count + 1);
						
			}
			
			JSONObject projJSONObj = new JSONObject();
			projJSONObj.put("phaseMap", phaseMap);
			arrayJSON.put(projJSONObj);

			projJSONObj = new JSONObject();
			projJSONObj.put("fundSourceMap", fundSourceMap);
			arrayJSON.put(projJSONObj);
			
			projJSONObj = new JSONObject();
			projJSONObj.put("locationMap", locationMap);
			arrayJSON.put(projJSONObj);
			
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public Project getProjectInfo(String username, String projectid) {
		Connection conn = null;
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement("select p.projectid, p.projectname, p.fundsource, p.projectphase, p.location, p.etpc, p.projectstart, p.beneficialocc, p.address, p.latlng, pm.name pmname, fars.totalfars from projects p join projectmanagers pm on p.projectmanagerid=pm.id left join (select projectid, IFNULL((sum(approvedfars) + sum(pendingfars)), 0) totalfars from fars group by projectid) fars on p.projectid=fars.projectid where p.projectid=?");
			// PreparedStatement ps = conn.prepareStatement("select p.*, pm.name from projects p join projectmanagers pm on p.projectmanagerid=pm.id where projectid=? order by beneficialocc");
			ps.setString(1, projectid);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				Project p = new Project(
						rs.getString("projectid"),
						rs.getString("projectname"),
						rs.getString("pmname"),
						rs.getString("fundsource"),
						rs.getString("projectphase"),
						rs.getString("location"),
						rs.getDouble("totalfars"),
						rs.getDouble("etpc"),
						rs.getDate("projectstart"),
						rs.getDate("beneficialocc"),
						rs.getString("address"),
						rs.getString("latlng")
				);
				return p;
			}
			else {
				return new Project();
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
	}
	
	public JSONArray getProjectFarInfoJSON(String username, String projectid) {
		Connection conn = null;
		//List<Far> list = new ArrayList<Far>();
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement("select * from fars where projectid=? order by fundname");
			ps.setString(1, projectid);
			ResultSet rs = ps.executeQuery();
			double totalApprovedFARs = 0.0;
			double totalPendingFARs = 0.0;
			while (rs.next()) {
				
				JSONObject farJSONObj = new JSONObject();
				farJSONObj.put("fundnumber", rs.getInt("fundnumber"));
				farJSONObj.put("fundsource", rs.getString("fundsource"));
				farJSONObj.put("fundname", rs.getString("fundname"));
				farJSONObj.put("approvedfars", rs.getDouble("approvedfars"));
				farJSONObj.put("pendingfars", rs.getDouble("pendingfars"));
				
				totalApprovedFARs += rs.getDouble("approvedfars");
				totalPendingFARs += rs.getDouble("pendingfars");
				
				arrayJSON.put(farJSONObj);
			}
			
			JSONObject farJSONObj = new JSONObject();
			farJSONObj.put("totalApprovedFARs", totalApprovedFARs);
			arrayJSON.put(farJSONObj);
			
			farJSONObj = new JSONObject();
			farJSONObj.put("totalPendingFARs", totalPendingFARs);
			arrayJSON.put(farJSONObj);
			
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getPms(String username) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement(""
					+ "select pm.id, pm.name, count(distinct p.projectid) projectcount, sum(p.etpc) etpc, sum(f.approvedfars) approvedfars, sum(f.pendingfars) pendingfars "
					+ "from projects p join projectmanagers pm on p.projectmanagerid=pm.id left outer join fars f on f.projectid=p.projectid "
					+ "group by pm.name, pm.id order by projectcount desc, pm.name");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject pmJSONObj = new JSONObject();
				
				pmJSONObj.put("pmid", rs.getInt("id"));
				pmJSONObj.put("pmname", rs.getString("name"));
				pmJSONObj.put("projectcount" ,rs.getInt("projectcount"));
				pmJSONObj.put("etpc", rs.getDouble("etpc"));
				pmJSONObj.put("approvedfars", rs.getDouble("approvedfars"));
				pmJSONObj.put("pendingfars", rs.getDouble("pendingfars"));
				
				arrayJSON.put(pmJSONObj);
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getPmDetail(String username, int pmid) {
		System.out.println("In getPmDetail DataDaoImpl func");
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement("select p.projectid, p.projectname, p.fundsource, p.projectphase, p.location, p.etpc, p.projectstart, p.beneficialocc, p.address, p.latlng, pm.name pmname, fars.totalfars from projects p join projectmanagers pm on p.projectmanagerid=pm.id left join (select projectid, IFNULL((sum(approvedfars) + sum(pendingfars)), 0) totalfars from fars group by projectid) fars on p.projectid=fars.projectid where p.projectmanagerid = ? order by beneficialocc");
			ps.setInt(1, pmid);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject projJSONObj = new JSONObject();
				
				projJSONObj.put("projectid", rs.getString("projectid"));
				projJSONObj.put("projectname", rs.getString("projectname"));
				projJSONObj.put("pmname", rs.getString("pmname"));
				projJSONObj.put("fundsource", rs.getString("fundsource"));
				projJSONObj.put("projectphase", rs.getString("projectphase"));
				projJSONObj.put("location", rs.getString("location"));
				projJSONObj.put("totalfars", rs.getDouble("totalfars"));
				projJSONObj.put("etpc", rs.getDouble("etpc"));
				projJSONObj.put("projectstart", rs.getDate("projectstart"));
				projJSONObj.put("beneficialocc", rs.getDate("beneficialocc"));
				projJSONObj.put("address", rs.getString("address"));
				projJSONObj.put("latlng", rs.getString("latlng"));
						
				arrayJSON.put(projJSONObj);
				
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getVendorsPrime(String username) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement(""
					+ "select v.vendorid, vendorname, sum(c.contractamount) contractamount, count(distinct c.projectid) projectcount from vendors v "
					+ "left join contracts    c  on v.vendorid=c.vendorid "
					//+ "left join amendments   a  on v.vendorid=a.vendorid "
					//+ "left join changeorders co on v.vendorid=co.vendorid "
					//+ "left join invoices     i  on v.vendorid=i.vendorid "
					+ "group by v.vendorid "
					+ "order by projectcount desc");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject pmJSONObj = new JSONObject();
				
				pmJSONObj.put("vendorid", rs.getString("vendorid"));
				pmJSONObj.put("vendorname", rs.getString("vendorname"));
				pmJSONObj.put("contractamount", rs.getDouble("contractamount"));
				pmJSONObj.put("projectcount", rs.getInt("projectcount"));
				
				arrayJSON.put(pmJSONObj);
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getVendorsSub(String username) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement(""
					+ "select s.subcontractorid, s.subcontractorname, sum(al.alamount) alamount, count(distinct al.projectid) projectcount, GROUP_CONCAT(al.trade) trades from subcontractors s "
					+ "left join approvalletters al on s.subcontractorid=al.subcontractorid "
					+ "group by s.subcontractorid "
					+ "order by projectcount desc");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject pmJSONObj = new JSONObject();
				
				pmJSONObj.put("subcontractorid", rs.getString("subcontractorid"));
				pmJSONObj.put("subcontractorname", rs.getString("subcontractorname"));
				pmJSONObj.put("alamount", rs.getDouble("alamount"));
				pmJSONObj.put("projectcount", rs.getInt("projectcount"));
				pmJSONObj.put("trades", rs.getString("trades"));
				
				arrayJSON.put(pmJSONObj);
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getVendorPrimeDetail(String username, String vendorid) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			String sql = ""
					+ "select distinct p.projectid, p.projectname, sum(c.contractamount) contractamount, sum(a.amendmentamount) amendmentamount, sum(co.changeorderamount) changeorderamount, "
					+ "sum(i.invoiceamount) invoiceamount from contracts c "
					+ "left join projects     p  on c.projectid=p.projectid "
					+ "left join amendments   a  on c.vendorid=a.vendorid "
					+ "left join changeorders co on c.vendorid=co.vendorid "
					+ "left join invoices     i  on c.vendorid=i.vendorid "
					+ "where c.vendorid = ?"
					+ "group by p.projectid, p.projectname "
					+ "order by p.projectid";
			System.out.println(sql);
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, vendorid);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject pmJSONObj = new JSONObject();
				
				pmJSONObj.put("projectid", rs.getString("projectid"));
				pmJSONObj.put("projectname", rs.getString("projectname"));
				pmJSONObj.put("contractamount", rs.getDouble("contractamount"));
				pmJSONObj.put("amendmentamount", rs.getDouble("amendmentamount"));
				pmJSONObj.put("changeorderamount", rs.getDouble("changeorderamount"));
				pmJSONObj.put("invoiceamount", rs.getDouble("invoiceamount"));
				
				arrayJSON.put(pmJSONObj);
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public JSONArray getVendorSubDetail(String username, String vendorid) {
		Connection conn = null;
		JSONArray arrayJSON = new JSONArray();
		try {
			conn = dataSource.getConnection();
			String sql = ""
					+ "select distinct p.projectid, p.projectname, sum(al.alamount) alamount, sum(co.changeorderamount) changeorderamount, al.trade "
					+ "from approvalletters al "
					+ "left join projects p on al.projectid=p.projectid "
					+ "left join changeorders co on co.projectid=p.projectid "
					+ "where al.subcontractorid = ? "
					+ "group by p.projectid, p.projectname "
					+ "order by p.projectid";
			System.out.println(sql);
			System.out.println("bind: " + vendorid);
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, vendorid);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				
				JSONObject pmJSONObj = new JSONObject();
				
				pmJSONObj.put("projectid", rs.getString("projectid"));
				pmJSONObj.put("projectname", rs.getString("projectname"));
				pmJSONObj.put("alamount", rs.getDouble("alamount"));
				pmJSONObj.put("changeorderamount", rs.getDouble("changeorderamount"));
				pmJSONObj.put("trade", rs.getString("trade"));

				arrayJSON.put(pmJSONObj);
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
		
		return arrayJSON;
	}
	
	public boolean validateUser(String username) {
		Connection conn = null;
		
		try {
			conn = dataSource.getConnection();
			PreparedStatement ps = conn.prepareStatement("select username from user where username = ?");
			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				System.out.println("username = " + username + " query results = " + rs.getString(1));
				ps.close();
				return true;
			}
			else {
				ps.close();
				return false;
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);

		} finally {
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {}
			}
		}
	}
		
}