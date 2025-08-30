SELECT CONCAT(m.name,if(ao.addOnID = 3,'',if(ao.addOnID = 1,'ร้อน','ปั่น'))) AS menuName
FROM menu m
	JOIN addOn ao 

-- 5 --
SELECT o.orderDate,
	b.location,
    e.firstName,
    CONCAT(m.name,' (', ao.name,')'),
    od.amount
FROM orders o
	JOIN orderDetail od ON o.orderID = od.orderID
	JOIN employee e ON o.employeeID = e.employeeID
    JOIN branch b ON o.branchID = b.branchID
    JOIN menu m ON od.menuID = m.menuID
	JOIN addOn ao ON od.addOnID = ao.addOnID
ORDER BY b.location





-- 6.2 --
SELECT b.location,TIMEDIFF( b.closeTime,b.openTime) AS openTimePerDay,
FROM orders o
	JOIN employee e ON o.employeeID = o.employeeID
	JOIN responsible r ON e.employeeID = r.employeeID
    JOIN branch b ON r.branchID = b.branchID
	JOIN orderDetail od ON o.orderID = od.orderID
    JOIN menu m ON od.menuID = m.menuID
    JOIN addOn ao ON od.addOnID = ao.addOnID


-- 6.3 --
SELECT
    e.firstName AS employeeName,
    b.location AS branchName,
    COUNT(o.orderID) AS orderCount
FROM
    employee e 
LEFT JOIN 
    responsible r ON e.employeeID = r.employeeID
LEFT JOIN 
    branch b ON r.branchID = b.branchID
LEFT JOIN 
    orders o ON e.employeeID = o.employeeID
GROUP BY
    e.employeeID, e.firstName, b.location
ORDER BY
    employeeName;