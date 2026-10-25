--Part A two numbers in one pass.

--Two questions answered in one query.
--What is the total volume of events handled by each producer?
--How many of those total events resulted in a failure or cancellation for each producer?
SELECT 
    driver_id AS producer_id,
    COUNT(trip_id) AS total_events,
    SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) AS failure_count
FROM trips
GROUP BY driver_id
ORDER BY total_events DESC;

--Part B
--he Regional Director requires subtotals per region rather than granular detail rows to review market-level performance efficiently without wading through individual producer records.
--The platform-wide grand total provides the macro benchmark needed for global resource allocation, capital budgeting, and platform-wide policy setting (such as adjusting baseline service level agreements or overall incentive structures), 
--which regional group rows alone cannot contextualize against the entire business.
SELECT 
    COALESCE(pickup_city, 'GRAND TOTAL') AS region,
    COUNT(trip_id) AS total_events,
    ROUND(SUM(fare_amount), 2) AS total_revenue
FROM trips
GROUP BY ROLLUP(pickup_city)
ORDER BY pickup_city NULLS LAST;

--Part C
--What is the overall performance baseline (such as average revenue and cancellation rate) specifically among high-volume producers who meet or exceed our minimum activity threshold?
WITH producer_summary AS (
    SELECT 
        driver_id,
        COUNT(trip_id) AS total_events,
        AVG(fare_amount) AS avg_fare,
        SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) * 100.0 / COUNT(trip_id) AS failure_rate_pct
    FROM trips
    GROUP BY driver_id
)
SELECT 
    ROUND(AVG(total_events), 2) AS avg_events_per_high_volume_producer,
    ROUND(AVG(avg_fare), 2) AS baseline_avg_fare,
    ROUND(AVG(failure_rate_pct), 2) AS baseline_failure_rate_pct
FROM producer_summary
WHERE total_events >= 10;