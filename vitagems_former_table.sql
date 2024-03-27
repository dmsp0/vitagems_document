-- 퇴사자 table

use HRDB;

-- 퇴사자 인적 정보 table 생성
CREATE TABLE formerEmployeeInformation ( 
-- 퇴사 시점의 정보를 담을 테이블이다. (비밀번호는 사라진다.)
-- 전사원 인적정보에서 넘어올 값은 주석으로 V 표시
-- 퇴사일이 포함된다.
	employeeCode VARCHAR(20) NOT NULL, -- 사원코드 V
    employeename VARCHAR(100) NOT NULL, -- 사원명 V
    department ENUM('MK', 'MN', 'DV') NOT NULL, -- 부서 V 
    employeeRank ENUM('사원', '대리','과장','차장','부장') NOT NULL, -- 직급 V
    joinDate DATE NOT NULL, -- 입사일 V
    departureDate DATE NOT NULL, -- 퇴사일
    
    birthday DATE NOT NULL, -- 생년월일 V
    gender ENUM('남', '여') NOT NULL, -- 성별 V
    employeePhoto BLOB, -- 사진 V
    phoneNum VARCHAR(20) NOT NULL, -- 전화번호 V
    email VARCHAR(100), -- 이메일 V
    address VARCHAR(255), -- 주소 V
    bankAccountNum VARCHAR(100), -- 계좌번호 (사내 회계 정보를 남기기 때문에 보관) V
    
    PRIMARY KEY (employeeCode) -- 기본키 : 사원코드
);

select * from formerEmployeeInformation;