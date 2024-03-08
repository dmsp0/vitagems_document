drop database if exists hrsystem;
create database hrsystem;
use hrsystem;

-- Create employee table
CREATE TABLE employee (
    employeeName VARCHAR(100) NOT NULL,
    rrn CHAR(14) NOT NULL,
    PhoneNum VARCHAR(20) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    employeerank VARCHAR(50) NOT NULL,
    JoinDate DATE NOT NULL,
    password VARCHAR(100) AS (CONCAT(SUBSTRING(Department, 1, 2), SUBSTRING(PhoneNum, -4))) STORED,
    gender ENUM('남자', '여자') AS (CASE WHEN SUBSTRING(rrn, 8, 1) IN ('1', '3') THEN '남자'
                                      WHEN SUBSTRING(rrn, 8, 1) IN ('2', '4') THEN '여자'
                                 END) STORED,
    address VARCHAR(255),
    BankaccountNum VARCHAR(100),
    email VARCHAR(100),
    employeePhoto BLOB,
    employeeCode VARCHAR(20) NOT NULL PRIMARY KEY,
    authority ENUM('user', 'admin') NOT NULL
);

-- Create a trigger to generate employeeCode automatically
DELIMITER //
CREATE TRIGGER employeeCode_generator BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    DECLARE 순서 INT;
    SET 순서 = (SELECT COUNT(*) FROM employee WHERE JoinDate = NEW.JoinDate AND Department = NEW.Department) + 1;
    SET NEW.employeeCode = CONCAT(YEAR(NEW.JoinDate), UPPER(SUBSTRING(NEW.Department, 1, 2)), LPAD(순서, 3, '0'));
END;
//
DELIMITER ;

-- Add a unique key constraint to prevent duplicate PhoneNum in the employee table
ALTER TABLE employee ADD UNIQUE INDEX idx_unique_PhoneNum (PhoneNum);
