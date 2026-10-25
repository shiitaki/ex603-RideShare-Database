
-- Q4_1.sql Theme's main metrics. 

--Query 1
SELECT 
    COUNT(*) AS total_trips_count,
    COUNT(DISTINCT rider_id) AS distinct_riders_count,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    MIN(fare_amount) AS min_fare,
    MAX(fare_amount) AS max_fare,
    ROUND(SUM(distance_km), 2) AS total_distance_km,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    MIN(distance_km) AS min_distance_km,
    MAX(distance_km) AS max_distance_km
FROM trips;
--Query 2
-- Query that calculates the event count and avg. mertric for each producer (driver) in the trips table.
SELECT 
    driver_id AS producer_id,
    COUNT(trip_id) AS event_count,
    ROUND(AVG(fare_amount), 2) AS avg_metric
FROM trips
GROUP BY driver_id
ORDER BY event_count DESC;
--This shows 13 drivers with various event counts and average fare amounts. The driver with the most rides is driver 6, and the driver with the highest average fare is driver 5.

--Query 3
-- Query that calculates the total events, canceled events, and cancellation rate for each driver.
SELECT 
    driver_id AS producer_id,
    COUNT(trip_id) AS total_events,
    SUM(CASE WHEN trip_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_events,
    ROUND(
        SUM(CASE WHEN trip_status = 'cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(trip_id), 
        2
    ) AS cancellation_rate_pct,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM trips
GROUP BY driver_id
HAVING COUNT(trip_id) >= 10
ORDER BY total_events DESC;

--This query shows the total number of trips, the number of cancelled trips, and the cancellation rate for each driver who has completed at least 10 trips. The results are ordered by the total number of trips in descending order. It shows one 
--metric as 0, which made me look closer,  but it is correct, because this driver has no cancelled trips, so the cancellation rate is 0%. The average fare for this driver is also shown.

--Query 4
--This query calculates the total events, active producers count, total revenue, average fare, average distance, cancelled trips count, and cancellation rate for each region (pickup city) in the trips table. 
SELECT 
    pickup_city AS region,
    COUNT(trip_id) AS total_events,
    COUNT(DISTINCT driver_id) AS active_producers_count,
    ROUND(SUM(fare_amount), 2) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    SUM(CASE WHEN trip_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_trips_count,
    ROUND(
        SUM(CASE WHEN trip_status = 'cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(trip_id), 
        2
    ) AS cancellation_rate_pct
FROM trips
GROUP BY pickup_city
ORDER BY total_revenue DESC;
--This query provides insights into the performance of each region (pickup city) by calculating the total number of trips, the count of active drivers, total revenue generated, average fare, average distance traveled, the number of cancelled trips, and the cancellation rate for each region. The results are ordered by total revenue in descending order, allowing for easy identification of the most profitable regions.
