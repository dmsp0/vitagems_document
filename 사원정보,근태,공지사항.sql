-- Create HRInformation table
create database hrdb;
use hrdb;

CREATE TABLE HRInformation (
    employeeName VARCHAR(100) NOT NULL,
    birthday DATE NOT NULL,
    PhoneNum VARCHAR(20) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    employeeRank VARCHAR(50) NOT NULL,
    JoinDate DATE NOT NULL,
    password VARCHAR(100) AS (CONCAT(SUBSTRING(Department, 1, 2), SUBSTRING(PhoneNum, -4))) STORED,
    gender ENUM('남', '여') NOT NULL,
    address VARCHAR(255),
    BankaccountNum VARCHAR(100),
    email VARCHAR(100),
    employeePhoto BLOB,
    employeeCode VARCHAR(20) NOT NULL PRIMARY KEY,
    authority ENUM('user', 'admin') NOT NULL
);

-- employeeCode 자동생성 트리거
DELIMITER //
CREATE TRIGGER employeeCode_generator BEFORE INSERT ON HRInformation
FOR EACH ROW
BEGIN
    DECLARE 순서 INT;
    SET 순서 = (SELECT COUNT(*) FROM HRInformation WHERE JoinDate = NEW.JoinDate AND Department = NEW.Department) + 1;
    SET NEW.employeeCode = CONCAT(YEAR(NEW.JoinDate), UPPER(SUBSTRING(NEW.Department, 1, 2)), LPAD(순서, 3, '0'));
END;
//
DELIMITER ;

-- department에 제약조건추가  'DV', 'MK', 'MN'
ALTER TABLE HRInformation ADD CONSTRAINT chk_Department CHECK (Department IN ('DV', 'MK', 'MN'));

-- employeeRank에 제약조건 추가 'B', 'S', 'G', 'P', 'D'
ALTER TABLE HRInformation ADD CONSTRAINT chk_employeeRank CHECK (employeeRank IN ('B', 'S', 'G', 'P', 'D'));
-- 전화번호 같은것은 저장못하는 제약조건
ALTER TABLE HRInformation ADD UNIQUE INDEX idx_unique_PhoneNum (PhoneNum);


CREATE TABLE attendance (
    employeeCode VARCHAR(20) NOT NULL,
    date DATE NOT NULL,
    arrivalTime TIME NOT NULL,
    departureTime TIME NOT NULL,
    status ENUM('businesstripCount', 'attendanceCount', 'outsideWorkCount', 'montlyLeave', 'halfDayLeave','lateness','earlyLeave','absence') NOT NULL,
    PRIMARY KEY (employeeCode, date),
    FOREIGN KEY (employeeCode) REFERENCES HRInformation (employeeCode)
);

-- 공지사항(announcement) 테이블 작성

CREATE TABLE announcement (
    notice_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id VARCHAR(20) NOT NULL,
    publish_date DATETIME NOT NULL,
    img LONGBLOB,
    PRIMARY KEY (notice_id),
    FOREIGN KEY (author_id) REFERENCES HRInformation (employeeCode)
);

-- admin만 작성,삭제,수정등의 권한 제약조건
ALTER TABLE announcement ADD CONSTRAINT chk_author_id CHECK (author_id IN (SELECT employeeCode FROM HRInformation WHERE authority = 'admin'));


