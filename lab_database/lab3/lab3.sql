-- 3.1 --
SELECT c.customerName,
	c.country AS customerCountry,
    e.firstName,
    e.lastName,
    o.state,
    o.country AS officeCountry
FROM customers AS c
	LEFT JOIN employees AS e ON c.salesRepEmployeeNumber = e.employeeNumber
    LEFT JOIN offices AS o ON o.officeCode = e.officeCode
WHERE c.country != o.country

-- 3.2 --
SELECT c.customerName,
	c.country AS customerCountry,
    e.firstName,
    e.lastName
FROM customers AS c
	LEFT JOIN employees AS e ON c.salesRepEmployeeNumber = e.employeeNumber
  LEFT JOIN offices AS o ON c.country = o.country
WHERE o.country IS NULL

-- 3.3 --











