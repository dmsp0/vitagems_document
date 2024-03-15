package employee;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dbconnection.MyDBConnection;

public class EmployeeDAO {

	private Connection con;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private String getAllEmployeeSQL = "select * from hrinformation";
	
	public List<EmployeeDTO> getAllEmployee() {
		
		ArrayList<EmployeeDTO> arreDTO = new ArrayList<>();
		con=MyDBConnection.getConnection();
		try {
			pstmt = con.prepareStatement(getAllEmployeeSQL);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				EmployeeDTO eDAO = new EmployeeDTO();
				
				eDAO.setEmployeeName(rs.getString(1));
				eDAO.setBirthday(rs.getDate(2));
				eDAO.setPhonenum(rs.getString(3));
				eDAO.setDepartment(rs.getString(4));
				eDAO.setEmployeeRank(rs.getString(5));
				eDAO.setJoinDate(rs.getDate(6));
				arreDTO.add(eDAO); // 리스트에 DTO 객체를 추가합니다.
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}finally {
			MyDBConnection.close(rs, pstmt, con);
		}
		
		return arreDTO;// 모든 사원 정보를 담은 리스트를 반환합니다.
	}
	
		 
	 
	
	
	

	
	
	
	
}
