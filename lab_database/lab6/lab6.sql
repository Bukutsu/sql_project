-- 1) Database Creation
DROP DATABASE IF EXISTS db25_002_cpephone;
CREATE DATABASE db25_002_cpephone DEFAULT CHARACTER SET utf8;
USE db25_002_cpephone;

-- 2) phoneNumber Table
DROP TABLE IF EXISTS phoneNumber;
CREATE TABLE phoneNumber(   
    phoneNo VARCHAR(10) PRIMARY KEY,
    status VARCHAR(10) NOT NULL DEFAULT 'Valid'
);

-- 3) Insert Data into phoneNumber
INSERT INTO phoneNumber(phoneNo)
VALUES      
    ('0901111111'), ('0902222222'), ('0903333333'), ('0904444444'), ('0905555555'),
    ('0941111111'), ('0942222222'), ('0943333333'), ('0944444444'), ('0945555555'),
    ('0951111111'), ('0952222222'), ('0953333333'), ('0954444444'), ('0955555555'),
    ('0991111111'), ('0992222222'), ('0993333333'), ('0994444444'), ('0995555555');

-- 4) package Table
DROP TABLE IF EXISTS package;
CREATE TABLE package(
    packageId   VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    price       FLOAT   NOT NULL,
    totalMin    FLOAT   NOT NULL,   
    totalNet    FLOAT   NOT NULL,   
    extMin      FLOAT   NOT NULL,       
    extNet      FLOAT   NOT NULL,   
    status      VARCHAR(10) NOT NULL DEFAULT 'INACTIVE'
);

-- 5) Insert Data into package
INSERT INTO package(packageId, name, price, totalMin, extMin, totalNet, extNet)
VALUES
    ('P001', 'CPE-Freshy',     50,  50,  2.00, 0.5, 0.20),
    ('P002', 'CPE-Standard',   100, 100, 1.50, 1,   0.15),
    ('P003', 'CPE-Max Call',   150, 200, 0.75, 0.8, 0.10),
    ('P004', 'CPE-Max Net',    180, 70,  1.00, 2,   0.08),
    ('P005', 'CPE-Senior',     250, 250, 0.5,  5,   0.05);
    
-- 6) Update phoneNumber Status
UPDATE phoneNumber
SET status = 'AVAILABLE'
WHERE phoneNo LIKE '090%' OR phoneNo LIKE '094%' OR phoneNo LIKE '095%';

-- 7) Update package Status
UPDATE package
SET status = 'ACTIVE'
WHERE packageId IN ('P001', 'P002', 'P003', 'P004');

-- 8) customer Table
DROP TABLE IF EXISTS customer;
CREATE TABLE customer(
    customerId  INT         PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(20) NOT NULL,
    lastName    VARCHAR(30) NOT NULL,
    address     VARCHAR(40) NOT NULL,
    subdistrict VARCHAR(30) NOT NULL,
    district    VARCHAR(30) NOT NULL,
    province    VARCHAR(30) NOT NULL    
);

-- 9) registNumber Table
DROP TABLE IF EXISTS registNumber;
CREATE TABLE registNumber(
    registNumberId  INT         PRIMARY KEY AUTO_INCREMENT,
    customerId      INT         NOT NULL,
    phoneNo         VARCHAR(10) NOT NULL,
    dateRegist      DATE        NOT NULL,
    status          VARCHAR(10) NOT NULL DEFAULT 'INUSE'
);

-- 10) Add Foreign Key from registNumber to customer
ALTER TABLE registNumber
ADD CONSTRAINT fk_registNumber_customer
FOREIGN KEY (customerId) REFERENCES customer(customerId);

-- 11) Add Foreign Key from registNumber to phoneNumber
ALTER TABLE registNumber
ADD CONSTRAINT fk_registNumber_phoneNumber
FOREIGN KEY (phoneNo) REFERENCES phoneNumber(phoneNo);

-- 12) Insert Customer and Registration Data
-- 12.1)
INSERT INTO customer(name, lastName, address, subdistrict, district, province)
VALUES ('กิจจา', 'พาสุข', '222 หมู่ 6', 'ต.กำแพงแสน', 'อ.กำแพงแสน', 'จ.นครปฐม');

SET @newCusId = LAST_INSERT_ID();
INSERT INTO registNumber(customerId, phoneNo, dateRegist)
VALUES (@newCusId, '0901111111', '2023-01-01');

UPDATE phoneNumber
SET status = 'INUSE'
WHERE phoneNo = '0901111111';

-- 12.2)
INSERT INTO customer(name, lastName, address, subdistrict, district, province)
VALUES ('ขจร', 'เขียวขจี', '444 ถนนด่านหน้า', 'ตําบลบางแก้ว', 'อําเภอบางพลี', 'จังหวัดสมุทรปราการ');

SET @newCusId = LAST_INSERT_ID();
INSERT INTO registNumber(customerId, phoneNo, dateRegist)
VALUES (@newCusId, '0942222222', '2023-01-08');

UPDATE phoneNumber
SET status = 'INUSE'
WHERE phoneNo = '0942222222';

-- 12.3)
INSERT INTO customer(name, lastName, address, subdistrict, district, province)
VALUES ('คมกริช', 'แก้วเกิด', '666', 'ตําบลบึงคําพร้อย', 'อําเภอลําลูกกา', 'จังหวัดปทุมธานี');

SET @newCusId = LAST_INSERT_ID();
INSERT INTO registNumber(customerId, phoneNo, dateRegist)
VALUES (@newCusId, '0904444444', '2023-01-10');

UPDATE phoneNumber
SET status = 'INUSE'
WHERE phoneNo = '0904444444';

-- 13) Select In-Use Phone Numbers with Customer Names
SELECT 
    p.phoneNo,
    c.name,
    c.lastName
FROM 
    phoneNumber AS p 
JOIN 
    registNumber AS r ON p.phoneNo = r.phoneNo
JOIN 
    customer AS c ON c.customerId = r.customerId
WHERE 
    p.status = 'INUSE';

-- 14) registPackage Table
DROP TABLE IF EXISTS registPackage;
CREATE TABLE registPackage(
    registPackageId INT PRIMARY KEY AUTO_INCREMENT,
    registNumberId  INT,
    packageId       VARCHAR(10) NOT NULL,   
    startDate       DATE NOT NULL,    
    endDate         DATE,       
    status          VARCHAR(10) NOT NULL DEFAULT 'INUSE'
);

-- 15) Add Foreign Key to registPackage
ALTER TABLE registPackage
ADD CONSTRAINT fk_registPackage_registNumber
FOREIGN KEY (registNumberId) REFERENCES registNumber(registNumberId);

-- 16) Register Packages for Existing Customers
SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0901111111');
INSERT INTO registPackage(packageId, registNumberId, startDate)
VALUES ('P001', @numberId, '2023-01-01');

SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0942222222');
INSERT INTO registPackage(packageId, registNumberId, startDate)
VALUES ('P002', @numberId, '2023-01-08');

SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0904444444');
INSERT INTO registPackage(packageId, registNumberId, startDate)
VALUES ('P003', @numberId, '2023-01-10');

-- 17) Stored Procedure for New Customer Registration
DROP PROCEDURE IF EXISTS newCus;
DELIMITER //
CREATE PROCEDURE newCus(
    name VARCHAR(20), 
    lastName VARCHAR(30),
    address VARCHAR(40), 
    subdistrict VARCHAR(30), 
    district VARCHAR(30),
    province VARCHAR(30), 
    phoneNoSelect VARCHAR(10), 
    startDate DATE, 
    packageId VARCHAR(10)
)
BEGIN
    INSERT INTO customer(name, lastName, address, subdistrict, district, province)
    VALUES(name, lastName, address, subdistrict, district, province);

    SET @newCusId = LAST_INSERT_ID();
    INSERT INTO registNumber(customerId, phoneNo, dateRegist)
    VALUES(@newCusId, phoneNoSelect, startDate);

    UPDATE phoneNumber
    SET status = 'INUSE'
    WHERE phoneNo = phoneNoSelect;
    
    SET @newregistNumberId = LAST_INSERT_ID();
    INSERT INTO registPackage(packageId, registNumberId, startDate)
    VALUES(packageId, @newregistNumberId, startDate);
END //
DELIMITER ;

-- 18) Call newCus Procedure
CALL newCus('อานนท์', 'มีสุข', '1 วัดปลากด', 'ตําบลบางกระสอ', 'อําเภอเมืองนนทบุรี', 'จังหวัดนนทบุรี', '0955555555', '2023-02-01', 'P001');
CALL newCus('อาทิตย์', 'สว่างศรี', '34 หมู่ 5', 'ตําบลแม่สอด', 'อําเภอแม่สอด', 'จังหวัดตาก', '0953333333', '2023-02-02', 'P002');
CALL newCus('อารักษ์', 'สายจันทร์', '553 ถนนบ้านลาด', 'ตําบลจันทนิมิต', 'อําเภอเมือง', 'จังหวัดจันทบุรี', '0944444444', '2023-02-03', 'P003');

-- 19) Stored Procedure to Change Package
DROP PROCEDURE IF EXISTS changePackage;
DELIMITER //
CREATE PROCEDURE changePackage(
    selectphoneNo VARCHAR(10), 
    newpackageId VARCHAR(10), 
    newstartDate DATE
)
BEGIN 
    -- Deactivate the current active package
    UPDATE registPackage
    SET status = 'CHANGE', endDate = DATE_SUB(newstartDate, INTERVAL 1 DAY)
    WHERE registNumberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = selectphoneNo) AND status = 'INUSE';

    -- Insert the new package registration
    INSERT INTO registPackage (registNumberId, packageId, startDate)
    VALUES ((SELECT registNumberId FROM registNumber WHERE phoneNo = selectphoneNo), newpackageId, newstartDate);
END //
DELIMITER ;

-- 20) Call changePackage Procedure
CALL changePackage('0901111111', 'P002', '2023-02-01');
CALL changePackage('0942222222', 'P003', '2023-02-01');

-- 21) Select Registrations by Date
SET @dateCheck = '2023-01-01';
SELECT 
    rn.phoneNo,
    c.name,
    c.lastName,
    p.name AS packageName
FROM customer c
INNER JOIN registNumber rn ON c.customerId = rn.customerId
INNER JOIN registPackage rp ON rn.registNumberId = rp.registNumberId
INNER JOIN package p ON rp.packageId = p.packageId
WHERE rn.dateRegist = @dateCheck AND rp.status = 'INUSE';

-- 22) callDetail Table
DROP TABLE IF EXISTS callDetail;
CREATE TABLE callDetail(
    callDetailId    INT PRIMARY KEY AUTO_INCREMENT,
    dateTimeCall    DATETIME NOT NULL,    
    fromNumber      VARCHAR(10) NOT NULL,    
    toNumber        VARCHAR(10) NOT NULL,    
    callDuration    INT NOT NULL    
);

-- 23) netDetail Table
DROP TABLE IF EXISTS netDetail;
CREATE TABLE netDetail(
    netDetailId     INT PRIMARY KEY AUTO_INCREMENT,
    dateTimeUsage   DATETIME NOT NULL,    
    fromNumber      VARCHAR(10) NOT NULL,    
    netAmount       FLOAT NOT NULL    
);

-- 24) Stored Procedure to Log a Call
DROP PROCEDURE IF EXISTS useCall;
DELIMITER //
CREATE PROCEDURE useCall(
    fromNumber VARCHAR(10), 
    toNumber VARCHAR(10), 
    dateTimeCall DATETIME, 
    callDuration INT
)
BEGIN
    INSERT INTO callDetail(dateTimeCall, fromNumber, toNumber, callDuration)
    VALUES(dateTimeCall, fromNumber, toNumber, callDuration);
END //
DELIMITER ;

-- 25) Stored Procedure to Log Net Usage
DROP PROCEDURE IF EXISTS useNET;
DELIMITER //
CREATE PROCEDURE useNET(
    dateTimeUsage DATETIME, 
    fromNumber VARCHAR(10), 
    netAmount FLOAT
)
BEGIN
    INSERT INTO netDetail(dateTimeUsage, fromNumber, netAmount)
    VALUES(dateTimeUsage, fromNumber, netAmount);
END //
DELIMITER ;

-- 26) Call useCall Procedure
CALL useCall('0901111111', '0942222222', '2023-01-09 10:23:10', 1320);
CALL useCall('0942222222', '0904444444', '2023-01-15 08:11:22', 900);

-- 27) Call useNET Procedure
CALL useNET('2023-01-10 15:10:10', '0942222222', 22.4);
CALL useNET('2023-02-05 18:14:10', '0944444444', 452.1);
