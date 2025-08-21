-- 1 --
DROP TABLE IF EXISTS registPackage;
CREATE TABLE registPackage(
		registPackageId int 		PRIMARY KEY AUTO_INCREMENT,
		registNumberId	int	,
		packageId		varchar(10)	NOT NULL,	
		startDate		date		NOT NULL,	
		endDate			date,		
		status			varchar(10)	NOT NULL	Default 'INUSE'
);

-- 2 --

ALTER TABLE registPackage
CREATE CONSTRAINT fk_registPackage_regisnumber
ADD FOREIGN KEY (registNumberId) REFERENCES registNumber(registNumberId);

-- 3 --
SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0901111111');
INSERT INTO registPackage(packageId,registNumberId,startDate)
VALUES	('P001',@numberId,'2023-01-01');

SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0942222222');
INSERT INTO registPackage(packageId,registNumberId,startDate)
VALUES	('P002',@numberId,'2023-01-08');

SET @numberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = '0904444444');
INSERT INTO registPackage(packageId,registNumberId,startDate)
VALUES	('P003',@numberId,'2023-01-10');

-- 4 --
DROP PROCEDURE IF EXISTS newCus;
delimiter //
CREATE PROCEDURE newCus(name VARCHAR(10), lastName  VARCHAR(30),
address  VARCHAR(40), subdistrict  VARCHAR(30), district  VARCHAR(30),
provice  VARCHAR(30), phoneNoSelect VARCHAR(10), startDate date, packageId varchar(10)) 
BEGIN
	INSERT INTO customer(name,lastName,address,subdistrict,district,provice)
		VALUES(name,lastName,address,subdistrict,district,provice);

	SET @newCusId =  LAST_INSERT_ID();
	INSERT INTO registNumber(customerId,phoneNo,dateRegist)
		VALUES(@newCusId,phoneNoSelect,startDate);

	UPDATE phoneNumber
	SET status = 'INUSE'
	WHERE phoneNo = phoneNoSelect;
	
	SET @newregistNumberId =  LAST_INSERT_ID();
	INSERT INTO registPackage(packageId,registNumberId,startDate)
		VALUES(packageId,@newregistNumberId,startDate);
END //
delimiter ;

-- 5 --
Call newCus('อานนท์','มีสุข','1 วัดปลากด','ตําบลบางกระสอ' ,'อําเภอเมืองนนทบุรี' ,'จังหวัดนนทบุรี','0955555555','2023-02-01','P001');
Call newCus('อาทิตย์','สว่างศรี ','34 หมู่ 5','ตําบลแม่สอด' ,'อําเภอแม่สอด' ,'จังหวัดตาก','0953333333','2023-02-02','P002');
Call newCus('อารักษ์','สายจันทร์','553 ถนนบ้านลาด','ตําบลจันทนิมิต ' ,'อําเภอเมือง ' ,'จังหวัดจันทบุรี','0944444444','2023-02-03','P003');

-- 6 --
DROP PROCEDURE IF EXISTS changePackage;
delimiter //
CREATE PROCEDURE changePackage(selectphoneNo VARCHAR(10),newpackageId varchar(10),newstartDate date)
BEGIN 
	UPDATE registPackage
	SET status = 'CHANGE',endDate = DATE_SUB(newstartDate,INTERVAL 1 DAY),startDate=newstartDate,packageId=newpackageId
	WHERE registNumberId = (SELECT registNumberId FROM registNumber WHERE phoneNo = selectphoneNo);

	INSERT INTO registPackage (registPackageId,packageId, startDate)
    VALUES ((SELECT registNumberId FROM registNumber WHERE phoneNo = selectphoneNo),newpackageId, newstartDate);
END //
delimiter ;

-- 7 --
Call changePackage('0901111111','P002','2023-02-01');
Call changePackage('0942222222','P003','2023-02-01');

-- 8 --
SET @dateCheck = '2023-01-01';
SELECT phoneNo,c.name,c.lastName,
	p.name AS packageName
FROM customer c
	INNER JOIN registNumber rn ON c.customerId = rn.customerId
	INNER JOIN registPackage rp ON rn.registNumberId = rp.registNumberId
    INNER JOIN  package p ON rp.packageId = p.packageId
WHERE rn.dateRegist = @dateCheck AND rp.status = 'INUSE'


-- 9 --
DROP TABLE IF EXISTS callDetail;
CREATE TABLE callDetail(
	callDetailId	int			PRIMARY KEY	AUTO_INCREMENT,
	dateTimeCall	datetime	NOT NULL,	
	fromNumber		varchar(10)	NOT NULL,	
	toNumber		varchar(10)	NOT NULL,	
	callDuration	int			NOT NULL	
);

-- 10 --
DROP TABLE IF EXISTS netDetail;
CREATE TABLE netDetail(
	netDetailId		int			PRIMARY KEY	AUTO_INCREMENT,
	dateTimeUsage	datetime	NOT NULL,	
	fromNumber		varchar(10)	NOT NULL,	
	netAmount		float		NOT NULL	
)

-- 11 --
DROP PROCEDURE IF EXISTS useCall;
delimiter //
CREATE PROCEDURE useCall(fromNumber varchar(10),toNumber varchar(10),dateTimeCall datetime,callDuration int)
	INSERT INTO callDetail(dateTimeCall,fromNumber,toNumber,callDuration)
	VALUES(dateTimeCall,fromNumber,toNumber,callDuration);
END //
delimiter ;

-- 12 --
DROP PROCEDURE IF EXISTS useNET;
delimiter //
CREATE PROCEDURE useNET(dateTimeUsage datetime,fromNumber varchar(10),netAmount float)
BEGIN
	INSERT INTO netDetail(dateTimeUsage,fromNumber,netAmount)
	VALUES(dateTimeUsage,fromNumber,netAmount);
END //
delimiter ;

-- 13 --
Call useCall('0901111111','0942222222','2023-01-09 10:23:10',1320);
Call useCall('0942222222','0904444444','2023-01-15 8:11:22',900);

-- 14 --
Call useNET('2023-01-10 15:10:10','0942222222',22.4);
Call useNET('2023-02-05 18:14:10','0944444444',452.1);