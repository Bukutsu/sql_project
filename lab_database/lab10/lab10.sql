
-- 5 --
SELECT t.transaction_code,
	c.first_name AS customer_name,
    tt.trip_code,
    departure_staton.station_name AS departure_station,
    ts.actual_arrival_time,
    destination_staton.station_name AS destination_station,
    ts.actual_daparture_time,
    /* price cal AS -- AS */ SUM(td.capacity * tpd.price) AS total_price
	
    
FROM transactions t
JOIN transaction_details td ON td.transaction_id = t.transaction_id
JOIN customers c ON c.customer_id = t.customer_id
JOIN train_trips tt ON t.trip_id = tt.trip_id
JOIN trip_stations ts ON tt.trip_id = ts.trip_id
JOIN routes r ON tt.route_id = r.route_id

JOIN stations departure_staton ON r.origin_station_id = departure_staton.station_id

JOIN stations destination_staton ON r.destination_station_id = destination_staton.station_id

JOIN train_trip_price_details tpd ON tt.trip_id = tpd.trip_id
GROUP BY transaction_code