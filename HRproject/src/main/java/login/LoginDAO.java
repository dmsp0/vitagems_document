package login;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dbconnection.MyDBConnection;


public class LoginDAO {

	private Connection con;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	//private String getidpwd = "select employeeCode,password from hrinformation where employeeCode=?"; 2023DV001// 입력한 아이디의 비밀번호가 맞는지
	private String getidpwd = "select employeeCode,employeepassword from hrinformation where employeeCode=?";
	public boolean doLogin(LoginDTO loginDto) {
		LoginDTO ld = null;
		try {
			con = MyDBConnection.getConnection();
			pstmt = con.prepareStatement(getidpwd);
			pstmt.setString(1, loginDto.getEmployeeCode());
			
			rs=pstmt.executeQuery();
			if(rs.next()) {
				ld = new LoginDTO();
				ld.setEmployeeCode(rs.getString(1));
				ld.setEmployeePassword(rs.getString(2));
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}finally {
			MyDBConnection.close(rs, pstmt, con);
		}
		
		if(ld != null&&ld.getEmployeeCode().equals(loginDto.getEmployeeCode())&&ld.getEmployeePassword().equals(loginDto.getEmployeePassword())) {
			return true;
		}else {
			return false;
		}
		
		
	}
	
	
}
