drop database if exists hrdb;
create database hrdb;
use hrdb;

-- 사원인적사항 테이블 생성
CREATE TABLE 사원인적사항 (
    사원명 VARCHAR(100) NOT NULL,
    주민번호 CHAR(14) NOT NULL,
    전화번호 VARCHAR(20) NOT NULL,
    부서 VARCHAR(50) NOT NULL,
    직급 VARCHAR(50) NOT NULL,
    입사일 DATE NOT NULL,
    비밀번호 VARCHAR(100) AS (CONCAT(SUBSTRING(부서, 1, 2), SUBSTRING(전화번호, -4))) STORED,
    성별 ENUM('남자', '여자') AS (CASE WHEN SUBSTRING(주민번호, 8, 1) IN ('1', '3') THEN '남자'
                                      WHEN SUBSTRING(주민번호, 8, 1) IN ('2', '4') THEN '여자'
                                 END) STORED,
    주소 VARCHAR(255),
    계좌번호 VARCHAR(100),
    이메일 VARCHAR(100),
    사진 BLOB,
    사원코드 VARCHAR(20) NOT NULL PRIMARY KEY,
    관리자여부 ENUM('user', 'admin') NOT NULL
);

-- 자동으로 사원코드 생성하는 트리거 
DELIMITER //
CREATE TRIGGER 사원코드_생성 BEFORE INSERT ON 사원인적사항
FOR EACH ROW
BEGIN
    DECLARE 순서 INT;
    SET 순서 = (SELECT COUNT(*) FROM 사원인적사항 WHERE 입사일 = NEW.입사일 AND 부서 = NEW.부서) + 1;
    SET NEW.사원코드 = CONCAT(YEAR(NEW.입사일), UPPER(SUBSTRING(NEW.부서, 1, 2)), LPAD(순서, 3, '0'));
END;
//
DELIMITER ;

-- 전화번호가 같으면 인적사항 테이블에 데이터를 저장하지 못하게하는 유니크키 제약추가
ALTER TABLE 사원인적사항 ADD UNIQUE INDEX idx_unique_전화번호 (전화번호);
-- 삭제할때 ALTER TABLE 사원인적사항 DROP INDEX idx_unique_전화번호;

-- insert into 사원인적사항(사원명,주민번호,전화번호,부서,직급,입사일,관리자여부) values('홍길동','900101-1234567', '010-1234-5678', '개발부', '주임', '2024-03-07','admin');
-- insert into 사원인적사항(사원명,주민번호,전화번호,부서,직급,입사일,관리자여부) values('홍길자','900101-1234567', '010-1234-5678', '개발부', '주임', '2024-03-07','admin');

select * from 사원인적사항;
-- drop table 개발부_사원;
-- drop table 사원인적사항;

-- delete from 사원인적사항 where 사원코드 = "2024개발002";
-- delete from 사원인적사항 where 사원코드 = "2024개발004";


CREATE TABLE 개발부_사원 (
    사원코드 VARCHAR(20) NOT NULL PRIMARY KEY,
    직급 VARCHAR(50) NOT NULL,
    사원명 VARCHAR(100) NOT NULL,
    전화번호 VARCHAR(20) NOT NULL,
    사진 BLOB,
    FOREIGN KEY (사원코드) REFERENCES 사원인적사항(사원코드) ON DELETE CASCADE
);

CREATE TABLE 영업부_사원 (
    사원코드 VARCHAR(20) NOT NULL PRIMARY KEY,
    직급 VARCHAR(50) NOT NULL,
    사원명 VARCHAR(100) NOT NULL,
    전화번호 VARCHAR(20) NOT NULL,
    사진 BLOB,
    FOREIGN KEY (사원코드) REFERENCES 사원인적사항(사원코드) ON DELETE CASCADE
);

CREATE TABLE 사업부_사원 (
    사원코드 VARCHAR(20) NOT NULL PRIMARY KEY,
    직급 VARCHAR(50) NOT NULL,
    사원명 VARCHAR(100) NOT NULL,
    전화번호 VARCHAR(20) NOT NULL,
    사진 BLOB,
    FOREIGN KEY (사원코드) REFERENCES 사원인적사항(사원코드) ON DELETE CASCADE
);






DELIMITER //
CREATE TRIGGER after_insert_사원인적사항
AFTER INSERT ON 사원인적사항
FOR EACH ROW
BEGIN
    CASE
        WHEN NEW.부서 = '개발부' THEN
            INSERT INTO 개발부_사원 (사원코드, 직급, 사원명, 전화번호, 사진)
            VALUES (NEW.사원코드, NEW.직급, NEW.사원명, NEW.전화번호, NEW.사진);
        WHEN NEW.부서 = '영업부' THEN
            INSERT INTO 영업부_사원 (사원코드, 직급, 사원명, 전화번호, 사진)
            VALUES (NEW.사원코드, NEW.직급, NEW.사원명, NEW.전화번호, NEW.사진);
		WHEN NEW.부서 = '사업부' THEN
            INSERT INTO 사업부_사원 (사원코드, 직급, 사원명, 전화번호, 사진)
            VALUES (NEW.사원코드, NEW.직급, NEW.사원명, NEW.전화번호, NEW.사진);
    END CASE;
END;

//
DELIMITER ;

-- drop TRIGGER if exists after_insert_사원인적사항;

select * from 개발부_사원;


-- 사원인적사항 테이블 작성완료 => 데이터입력될때 조건들 설정완료, 자동으로 사원코드 생성하는 트리거 작성완료
-- 전화번호가 같으면 인적사항 테이블에 데이터를 저장하지 못하게하는 유니크키 제약추가완료
-- 사원인적사항에 데이터 추가시 자동으로 부서별코드를 확인해서 부서별 테이블에도 데이터를 추가하는 트리거 작성완료

-- 각 부서별 테이블 작성완료
-- FOREIGN KEY (사원코드) REFERENCES 사원인적사항(사원코드) ON DELETE CASCADE 를 사용해서
--  사원인적사항 테이블에서 데이터가 삭제되면 자동으로 부서별 테이블에서도 해당데이터가 삭제되게 적용

-- 작성해야 할 것
-- 사원인적사항 테이블에서 delete,update,insert가 일어날시 다른 테이블에도 영향을 미치는 트리거 작성하기
-- 1. 사원인적사항에서 update될시 부서별테이블에서도 update
-- 1-1. 해당항목 : 직급, 사원명, 전화번호, 사진
-- 비밀번호를 사용자가 변경시 null값 불가능 등 제약조건 걸어야함 
