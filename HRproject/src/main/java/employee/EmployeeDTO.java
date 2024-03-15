package employee;

import java.util.Date;

public class EmployeeDTO {
private String employeeName;
private Date birthday;
private String phonenum;
private String department;
private String employeeRank;
private Date joinDate;




public String getEmployeeName() {
	return employeeName;
}
public void setEmployeeName(String employeeName) {
	this.employeeName = employeeName;
}
public Date getBirthday() {
	return birthday;
}
public void setBirthday(Date birthday) {
	this.birthday = birthday;
}
public String getPhonenum() {
	return phonenum;
}
public void setPhonenum(String phonenum) {
	this.phonenum = phonenum;
}
public String getDepartment() {
	return department;
}
public void setDepartment(String department) {
	this.department = department;
}
public String getEmployeeRank() {
	return employeeRank;
}
public void setEmployeeRank(String employeeRank) {
	this.employeeRank = employeeRank;
}
public Date getJoinDate() {
	return joinDate;
}
public void setJoinDate(Date joinDate) {
	this.joinDate = joinDate;
}



}
