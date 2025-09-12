
-- 5 --
SELECT t.transaction_code,
	c.first_name AS customer_name,
    tt.trip_code,
    departure_staton.station_name AS departure_station,
    departure_ts.actual_departure_time,
    destination_staton.station_name AS destination_station,
    destination_ts.actual_arrival_time,
    SUM(td.capacity * tpd.price) AS total_price
	
FROM transactions t
JOIN train_trips tt ON t.trip_id = tt.trip_id
JOIN train_trip_price_details tpd ON tt.trip_id = tpd.trip_id
JOIN transaction_details td ON td.transaction_id = t.transaction_id AND tpd.level = td.level
JOIN customers c ON c.customer_id = t.customer_id


JOIN routes r ON tt.route_id = r.route_id

JOIN stations departure_staton ON r.origin_station_id = departure_staton.station_id
JOIN stations destination_staton ON r.destination_station_id = destination_staton.station_id

LEFT JOIN trip_stations departure_ts ON tt.trip_id = departure_ts.trip_id AND r.origin_station_id = departure_ts.station_id
LEFT JOIN trip_stations destination_ts ON tt.trip_id = destination_ts.trip_id AND r.destination_station_id = destination_ts.station_id


GROUP BY t.transaction_code,
	c.first_name,
    tt.trip_code,
    departure_staton.station_name,
    departure_ts.actual_departure_time,
    destination_staton.station_name,
    destination_ts.actual_arrival_time
ORDER BY transaction_code;

-- 6 --
SELECT tt.trip_code,
	all_level.carriage_level,
	trip_carriage_capacity.total_capacity,
    (trip_carriage_capacity.total_capacity - level_requires.total_require) AS seat_left
FROM train_trips tt
JOIN (SELECT DISTINCT trip_id,carriage_level FROM trip_carriages) all_level ON tt.trip_id = all_level.trip_id
JOIN (SELECT t.trip_id,
tc.carriage_level,
SUM(tc.capacity) AS total_capacity
FROM train_trips t
JOIN trip_carriages tc ON t.trip_id = tc.trip_id

GROUP BY t.trip_id,
tc.carriage_level
) trip_carriage_capacity ON tt.trip_id = trip_carriage_capacity.trip_id AND all_level.carriage_level = trip_carriage_capacity.carriage_level

JOIN (SELECT t.trip_id AS level_require_trip_id,
	td.level_require,
	SUM(capacity) AS total_require
FROM transactions t
JOIN transaction_details td ON t.transaction_id = td.transaction_id
GROUP BY t.trip_id,td.level_require
) level_requires ON tt.trip_id = level_requires.level_require_trip_id AND all_level.carriage_level = level_requires.level_require


-- 7 --
SELECT
    r.route_code,
    s.station_name,
    IFNULL(ROUND(AVG(TIMESTAMPDIFF(MINUTE, ts.actual_arrival_time,rs.arrival_time )), 2),0) AS 'avg_time_arrival_delay(min)',
    IFNULL(ROUND(AVG(TIMESTAMPDIFF(MINUTE, ts.actual_departure_time,rs.departure_time)), 2),0) AS 'avg_time_departure_delay(min)'
FROM
    route_stations rs
JOIN
    routes r ON rs.route_id = r.route_id
JOIN
    stations s ON rs.station_id = s.station_id
LEFT JOIN
    train_trips tt ON rs.route_id = tt.route_id
LEFT JOIN
    trip_stations ts ON tt.trip_id = ts.trip_id AND rs.station_id = ts.station_id

GROUP BY
    r.route_code, s.station_name

ORDER BY
    r.route_code, MIN(rs.stop_order);