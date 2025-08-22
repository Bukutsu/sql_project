-- 1 --
Call useCall('0901111111','0904444444','2023-01-09 10:10:10',65);
Call useCall('0904444444','0901111111','2023-01-10 10:10:10',78);
Call useCall('0901111111','0953333333','2023-02-09 10:10:10',20);
Call useCall('0901111111','0955555555','2023-02-12 10:10:10',50);
Call useCall('0955555555','0944444444','2023-02-15 10:10:10',32);
Call useCall('0942222222','0942222222','2023-02-18 10:10:10',53);
Call useCall('0953333333','0955555555','2023-02-22 10:10:10',45);
Call useCall('0955555555','0953333333','2023-02-26 10:10:10',45);
Call useCall('0942222222','0901111111','2023-02-27 10:10:10',45);

-- 2 --
Call useNET('2023-01-12 09:09:09','0942222222',615);
Call useNET('2023-01-15 09:09:09','0904444444',418);
Call useNET('2023-01-17 09:09:09','0904444444',666);
Call useNET('2023-01-20 09:09:09','0942222222',810);
Call useNET('2023-02-08 09:09:09','0901111111',613);
Call useNET('2023-02-11 09:09:09','0955555555',312);
Call useNET('2023-02-14 09:09:09','0944444444',618.5);
Call useNET('2023-02-17 09:09:09','0901111111',155.8);
Call useNET('2023-01-20 09:09:09','0955555555',515);
Call useNET('2023-01-23 09:09:09','0953333333',142);

-- 3 --
DROP FUNCTION IF EXISTS getPackage;
DELIMITER //
CREATE FUNCTION getPackage(checkDate date, phoneNoCheck VARCHAR(10))
RETURNS VARCHAR(10)
BEGIN
	DECLARE pacNo VARCHAR(10);
	SET pacNo = (SELECT packageId FROM registPackage rp
										INNER JOIN registNumber rn ON rp.registNumberId = rn.registNumberId
                                    	INNER JOIN phoneNumber pn ON rn.phoneNo = pn.phoneNo
                                      	WHERE pn.phoneNo = phoneNoCheck AND LAST_DAY(checkDate) = LAST_DAY(rp.startDate)
										LIMIT 1);
RETURN pacNo;
END //
DELIMITER ;

-- 4 --
SET @dateCheck = '2023-01-01';
SELECT phoneNo, getPackage(@dateCheck,phoneNo) as packNo 
FROM phoneNumber
WHERE getPackage(@dateCheck,phoneNo) IS NOT NULL;

-- 5 --
DROP FUNCTION IF EXISTS totalCall;
DELIMITER //
CREATE FUNCTION totalCall(checkDate date, phoneNoCheck VARCHAR(10))
RETURNS int
BEGIN
	DECLARE totalCalled int; 
	SET totalCalled = (SELECT SUM(cd.callDuration)FROM callDetail cd
                       WHERE MONTH(checkDate) = MONTH(cd.dateTimeCall) AND cd.fromNumber = phoneNoCheck
                       GROUP BY cd.fromNumber 
                      );

RETURN if(ISNULL(totalCalled),0,totalCalled);
END //
DELIMITER ;

-- 6 --
SET @dateCheck = '2023-01-01';
SELECT phoneNo, totalCall(@dateCheck, phoneNo) as total 
FROM phoneNumber; 

SET @dateCheck = '2023-02-01';
SELECT phoneNo, totalCall(@dateCheck, phoneNo) as total 
FROM phoneNumber; 

-- 7 --
DROP FUNCTION IF EXISTS totalNet;
DELIMITER //
CREATE FUNCTION totalNet(checkDate date, phoneNoCheck VARCHAR(10))
RETURNS float
BEGIN
	DECLARE totalNet float; 
	SET totalNet = (SELECT SUM(nd.netAmount)
                    	FROM netDetail nd
                        WHERE MONTH(checkDate) = MONTH(nd.dateTimeUsage) AND nd.fromNumber = phoneNoCheck
                        GROUP BY nd.fromNumber 
                      );

RETURN if(ISNULL(totalNet),0,totalNet);
END //
DELIMITER ;

-- 8 --
SET @dateCheck = '2023-01-01'; 
SELECT phoneNo, totalNet(@dateCheck, phoneNo) as total  
FROM phoneNumber; 

SET @dateCheck = '2023-02-01'; 
SELECT phoneNo, totalNet(@dateCheck, phoneNo) as total  
FROM phoneNumber; 

-- 9 --
DROP FUNCTION IF EXISTS calCost;
DELIMITER //
CREATE FUNCTION calCost(checkDate date, phoneNoCheck VARCHAR(10))
RETURNS float
BEGIN
	DECLARE cost float; 
	SET cost = (SELECT price 
				FROM phoneNumber pn
                INNER JOIN registNumber rn ON pn.phoneNo = rn.phoneNo
                INNER JOIN registPackage rp ON rn.registNumberId = rp.registNumberId
               	INNER JOIN package p ON rp.packageId = p.packageId
                WHERE phoneNumber = phoneNoCheck
              );
					                                          
RETURN cost;
END //
DELIMITER ;

-- 9 --
DROP FUNCTION IF EXISTS calCost;
DELIMITER //
CREATE FUNCTION calCost(checkDate date, phoneNoCheck VARCHAR(10))
RETURNS float
BEGIN
	DECLARE totalCost float;
    DECLARE currentPackageId VARCHAR(10);
	DECLARE currentTotalCall int;
	DECLARE currentTotalMinPackage float;  
	DECLARE currentExtraMinPackage float;
	DECLARE currentTotalNet int;
	DECLARE currentNetAmountPackage float; 
	DECLARE currentExtraNetPackage float;

	SET currentPackageId = getPackage(checkDate,phoneNoCheck);
	SET currentTotalCall = totalCall(checkDate,phoneNoCheck); 
	SET currentTotalMinPackage = (SELECT p.totalMin FROM package p where p.packageId = currentPackageId);
	SET currentExtraMinPackage = (SELECT p.extMin FROM package p where p.packageId = currentPackageId);
	SET currentTotalNet = totalNet(checkDate,phoneNoCheck); 
	SET currentNetAmountPackage = (SELECT p.totalNet FROM package p where p.packageId = currentPackageId);
	SET currentExtraNetPackage = (SELECT p.extNet FROM package p where p.packageId = currentPackageId);
	SET totalCost = (SELECT p.price FROM package p where p.packageId = currentPackageId);

    IF currentTotalCall > currentTotalMinPackage THEN
        SET totalCost = totalCost + ((currentTotalCall - currentTotalMinPackage) * currentExtraMinPackage);
    END IF;

    IF currentTotalNet > currentNetAmountPackage THEN
        SET totalCost = totalCost + ((currentTotalNet - currentNetAmountPackage) * currentExtraNetPackage);
    END IF;
                                          
RETURN totalCost;
END //
DELIMITER ;

-- 10 --
SET @dateCheck = '2023-01-01'; 
SELECT pn.phoneNo,
	name AS packageName,
    price AS normalPackagePrice,
    totalCall(@dateCheck,phoneNo) AS totalCall,
    totalNet(@dateCheck,phoneNo) AS totalNet,
    calCost(@dateCheck,phoneNo) AS dueAmount
FROM phoneNumber pn
	JOIN package ON package.packageId = getPackage(@dateCheck,phoneNO);
