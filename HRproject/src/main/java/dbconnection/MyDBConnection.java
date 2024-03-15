package dbconnection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static dbconnection.DBCon.*;

public class MyDBConnection {
//	public static void main(String[] args) {
//		getConnection();
//		close(null, null, getConnection());
//	}
	
public static Connection getConnection() {
	Connection con = null;
	
	
	try {
		Class.forName("com.mysql.cj.jdbc.Driver");
		con = DriverManager.getConnection(URL, USER, PASSWORD);
		System.out.println("접속 성공");
	} catch (ClassNotFoundException e) {
		e.printStackTrace();
	} catch(SQLException e) {
		System.out.println("접속 실패");
	}
	return con;
	
}

public static void close(ResultSet rs,PreparedStatement pstmt,Connection con) {
	if(rs != null) {
		try {
			rs.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	if(pstmt !=null) {
		try {
			pstmt.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	if(con != null) {
		try {
			con.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	System.out.println("접속해제");
}// close





}// class
