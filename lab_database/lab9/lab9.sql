
-- 11.1 --
SELECT fs.flight_code,
st.type,
COUNT(fs.flight_steat_id)
FROM flight_seats fs
INNER JOIN seats s ON s.seat_code = fs.seat_code and s.aircraft_code  = fs.aircraft_code
INNER JOIN seats_types st ON s.seat_type_id = st.type_id
WHERE fs.status = "Available"
GROUP BY fs.flight_code,st.type

-- 11.2 --
SELECT b.booking_date,
c.name,
COUNT(bd.booking_details_id) as seat_count,
SUM(CASE st.type
	WHEN 'First Class' THEN f.first_class_price
	WHEN 'Business Class' THEN f.business_price
    WHEN 'Economy Class' THEN f.economy_price
    END + 
  	IFNULL(el.price, 0) +
    IFNULL(mo.total_meal_price, 0)
) as total_price
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN booking_details bd ON bd.booking_id = b.booking_id
JOIN seats_types st ON bd.seats_types_id = st.type_id
JOIN flights f ON b.flight_code = f.flight_code
LEFT JOIN extra_luggage el ON el.extra_luggage_id = bd.extra_luggage_id
LEFT JOIN (
	SELECT bd.passenger_id,
    SUM(m.price * mo.quantity) AS total_meal_price
	FROM meal_orders mo
    JOIN meals m  ON m.meal_id = mo.meal_id
	JOIN booking_details bd ON mo.passenger_id = bd.passenger_id
	GROUP BY bd.passenger_id
) mo ON bd.passenger_id = mo.passenger_id

GROUP BY bd.booking_id

-- 11.3 --
SELECT f.flight_code,
sc.seat_count AS total_seat_count,
el.total_weight AS total_extra_weight
FROM flights f
JOIN (SELECT fs.flight_code,
	COUNT(fs.flight_steat_id) as seat_count
	FROM flight_seats fs
	WHERE fs.status = "Unavailable"
	GROUP BY fs.flight_code
     ) sc ON f.flight_code = sc.flight_code
     
LEFT JOIN (SELECT b.flight_code,
      SUM(el.weight) as total_weight
    FROM bookings b
	JOIN booking_details bd ON bd.booking_id = b.booking_id
	JOIN extra_luggage el ON el.extra_luggage_id = bd.extra_luggage_id
	JOIN check_in ci ON bd.booking_id = ci.booking_id AND  bd.passenger_id = ci.passenger_id
      GROUP BY b.flight_code
	) el ON f.flight_code = el.flight_code

GROUP BY f.flight_code

-- 11.4 --
SELECT f.flight_code,
meal_count.name,
meal_count.total_meal_count AS meal_count
FROM flights f
JOIN flight_menus fm ON f.flight_code = fm.flight_code
JOIN (SELECT b.flight_code,
      m.name,
      SUM(mo.quantity) AS total_meal_count
	FROM bookings b 
	JOIN booking_details bd ON bd.booking_id = b.booking_id
    JOIN passengers p ON bd.passenger_id = p.passenger_id
	JOIN meal_orders mo ON mo.passenger_id = p.passenger_id
	JOIN meals m ON mo.meal_id = m.meal_id
      JOIN check_in ci ON bd.booking_id = ci.booking_id AND  bd.passenger_id = ci.passenger_id
	GROUP BY  b.flight_code,m.name
) meal_count ON f.flight_code = meal_count.flight_code

GROUP BY f.flight_code,meal_count.name