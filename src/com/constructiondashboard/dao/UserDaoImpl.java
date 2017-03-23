package com.constructiondashboard.dao;


import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.sql.DataSource;

import com.constructiondashboard.dao.UserDao;

public class UserDaoImpl implements UserDao {

	DataSource dataSource ;

	public DataSource getDataSource()
	{
		return this.dataSource;
	}

	public void setDataSource(DataSource dataSource)
	{
		this.dataSource = dataSource;
	}

	@Override
	public boolean isValidUser(String username, String password) throws SQLException
	{
		System.out.println("IN isValidUser!!!");
		String query = "Select username from user where username = ?";
		PreparedStatement pstmt = dataSource.getConnection().prepareStatement(query);
		pstmt.setString(1, username);
		// pstmt.setString(2, password);
		ResultSet resultSet = pstmt.executeQuery();
		System.out.println(pstmt.toString());
		if(resultSet.next()) {
			System.out.println("USER FOUND!!!");
		    //return (resultSet.getInt(1) > 0);
		    return true;
		}
        else {
			System.out.println("Couldn't find user in database!!!");
			return false;
        }
       }

}