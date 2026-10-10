--3.1 Active, highly rated drivers - the producers whose records
--Anchor the audit. Requirement: SELECT, WHERE, ORDER BY, LIMIT.

--1. Find the top 10 active drivers with an average rating of 4.5 or higher.
SELECT driver_id, driver_name,avg_rating
FROM drivers
WHERE is_active = TRUE
AND avg_rating >= 4.5
ORDER BY avg_rating DESC
LIMIT 10;   
--2.Find all possible event statuses for the trips table. Display the distinct values in the event status column.
--look carefully at the results. Are there more statuses than you expected? 
SELECT DISTINCT trip_status FROM trips;

--Because I used distinct, I only got the unique values in the trip_status column. I expected to see 3 statuses.
--3. Filter the events in two different ways. Write: one query that filters a nummber range, and one query 
--that filters using an explicit list of values with IN.

-- Trips with fares from 10 to 50, inclusive
SELECT trip_id, fare_amount, trip_status
FROM trips
WHERE fare_amount BETWEEN 10 AND 50;

-- Trips with any of these statuses
SELECT trip_id, trip_status
FROM trips
WHERE trip_status IN ('cancelled', 'completed', 'disputed');
--4 Work with text and missing values. Write queries that: find producers whose names match
--a text patter using like, and identify records where a reason/value is missing (null). Use a coalesce
--to replace a missing value with a useful label such as: No reason provided.
-- Find drivers whose names start with "Driver".
SELECT driver_id, driver_name
FROM drivers
WHERE driver_name LIKE '%01';

-- Find trips with no cancellation reason and show a label.
SELECT trip_id,
       COALESCE(cancellation_reason, 'No reason provided') AS cancellation_reason
FROM trips
WHERE cancellation_reason IS NULL;
--5 Make the results easier to understand. Create a query with calculated/computed colums that
--would make sense to someone who does not work with SQL. Depending on your theme, you might 
--calculate a payout amount, a time, a rating, or a useful business measure.
SELECT driver_name,
       avg_rating AS average_customer_rating,
       CASE
           WHEN avg_rating IS NULL THEN 'Not yet rated'
           WHEN avg_rating >= 4.5 THEN 'Excellent'
           WHEN avg_rating >= 4.0 THEN 'Good'
           ELSE 'Needs improvement'
       END AS rating_category
FROM drivers
ORDER BY avg_rating DESC NULLS LAST;