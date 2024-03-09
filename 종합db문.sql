-- Create HRInformation table
drop database if exists hrdb;
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

drop trigger if exists employeeCode_generator;
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
    arrivalTime TIME,
    departureTime TIME,
    status ENUM('businesstrip', 'attendance', 'outsideWork', 'montlyLeave', 'halfDayLeave','lateness','earlyLeave','absence') NOT NULL,
    PRIMARY KEY (employeeCode, date),
    FOREIGN KEY (employeeCode) REFERENCES HRInformation (employeeCode)
);


CREATE TABLE totalattendance (
    employeeCode VARCHAR(20) NOT NULL PRIMARY KEY,
    employeeName VARCHAR(100) NOT NULL,
    totalWorkCount INT(20) DEFAULT 0,
    attendanceCount INT(20) DEFAULT 0,
    businesstripCount INT(20) DEFAULT 0,
    outsideWorkCount INT(20) DEFAULT 0,
    Vacation INT(20) DEFAULT 0,
    montlyLeave INT(20) DEFAULT 0,
    halfDayLeave INT(20) DEFAULT 0,
    lateness INT(20) DEFAULT 0,
    earlyLeave INT(20) DEFAULT 0,
    absence INT(20) DEFAULT 0
);

-- 트리거 설명
-- attendance테이블에 새로운 출근 데이터가 추가될때 totalattendance테이블을 자동으로 업데이트 하는 트리거
-- 새로운 사원이 추가될때는 그 사원의 데이터를 totalattendance에 삽입하고,
-- 기존사원의 출근 데이터가 추가될때는 해당 사원의 근무 통계를 업데이트 함

drop trigger if exists after_attendance_insert;

DELIMITER //

CREATE TRIGGER after_attendance_insert
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
    -- 새로운 사원의 데이터를 totalattendance에 삽입
    IF NOT EXISTS (SELECT * FROM totalattendance WHERE employeeCode = NEW.employeeCode) THEN
        INSERT INTO totalattendance (employeeCode, employeeName, totalWorkCount, attendanceCount, businesstripCount, outsideWorkCount, Vacation, montlyLeave, halfDayLeave, lateness, earlyLeave, absence)
        SELECT NEW.employeeCode, employeeName, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM HRInformation WHERE employeeCode = NEW.employeeCode;
    END IF;

    -- 기존 사원의 근무 통계를 업데이트
    UPDATE totalattendance
    SET totalWorkCount = totalWorkCount + IF(NEW.status IN ('attendance', 'businesstrip', 'outsideWork'), 1, 0),
        attendanceCount = attendanceCount + IF(NEW.status = 'attendance', 1, 0),
        businesstripCount = businesstripCount + IF(NEW.status = 'businesstrip', 1, 0),
        outsideWorkCount = outsideWorkCount + IF(NEW.status = 'outsideWork', 1, 0),
        Vacation = Vacation + IF(NEW.status IN ('montlyLeave', 'halfDayLeave'), 1, 0),
        montlyLeave = montlyLeave + IF(NEW.status = 'montlyLeave', 1, 0),
        halfDayLeave = halfDayLeave + IF(NEW.status = 'halfDayLeave', 1, 0),
        lateness = lateness + IF(NEW.status = 'lateness', 1, 0),
        earlyLeave = earlyLeave + IF(NEW.status = 'earlyLeave', 1, 0),
        absence = absence + IF(NEW.status = 'absence', 1, 0)
    WHERE employeeCode = NEW.employeeCode;
END;
//
DELIMITER ;


-- 갱신 하는 쿼리

-- 총근무일수 갱신
UPDATE totalattendance
SET totalWorkCount = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status IN ('businesstrip', 'attendance', 'outsideWork')
    AND employeeCode = totalattendance.employeeCode
);

-- 출근일수 갱신
UPDATE totalattendance
SET attendanceCount = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'attendance'
    AND employeeCode = totalattendance.employeeCode
);

-- 출장일수 갱신
UPDATE totalattendance
SET businesstripCount = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'businesstrip'
    AND employeeCode = totalattendance.employeeCode
);

-- 외근일수 갱신
UPDATE totalattendance
SET outsideWorkCount = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'outsideWork'
    AND employeeCode = totalattendance.employeeCode
);

-- 휴가일수 갱신
UPDATE totalattendance
SET Vacation = (
    SELECT FLOOR(COUNT(status) / 2) + (COUNT(status) % 2) * 0.5
    FROM attendance
    WHERE status IN ('montlyLeave', 'halfDayLeave')
    AND employeeCode = totalattendance.employeeCode
);

-- 월차일수 갱신
UPDATE totalattendance
SET montlyLeave = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'montlyLeave'
    AND employeeCode = totalattendance.employeeCode
);

-- 반차일수 갱신
UPDATE totalattendance
SET halfDayLeave = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'halfDayLeave'
    AND employeeCode = totalattendance.employeeCode
);

-- 지각일수 갱신
UPDATE totalattendance
SET lateness = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'lateness'
    AND employeeCode = totalattendance.employeeCode
);

-- 조퇴일수 갱신
UPDATE totalattendance
SET earlyLeave = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'earlyLeave'
    AND employeeCode = totalattendance.employeeCode
);

-- 결근일수 갱신
UPDATE totalattendance
SET absence = (
    SELECT COUNT(status)
    FROM attendance
    WHERE status = 'absence'
    AND employeeCode = totalattendance.employeeCode
);

-- 공지사항(announcement) 테이블 작성
drop table if exists announcement;

CREATE TABLE announcement (
    noticeid INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    authorid VARCHAR(20) NOT NULL,
    publishdate DATETIME NOT NULL,
    img LONGBLOB,
    PRIMARY KEY (noticeid),
    FOREIGN KEY (authorid) REFERENCES HRInformation (employeeCode)
);

-- admin만 작성,삭제,수정등의 권한 제약조건 (제약조건 생성할때 다른테이블을 참조할수없어서 트리거로 변경)
DELIMITER //
CREATE TRIGGER chk_author_id BEFORE INSERT ON announcement
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HRInformation WHERE employeeCode = NEW.authorid AND authority = 'admin') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '관리자만 작성 할 수 있습니다.';
    END IF;
END;
//
DELIMITER ;

select * from attendance;
select * from hrinformation;
select * from totalattendance;
select * from announcement;

