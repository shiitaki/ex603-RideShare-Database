--Part True, False or Unknown. 

-- Count trips whose reason is not "Rider cancelled".
SELECT COUNT(*) AS returned_rows
FROM trips
WHERE cancellation_reason != 'Rider cancelled';

-- Count rows omitted because their reason is NULL.
SELECT COUNT(*) AS omitted_null_reason_rows
FROM trips
WHERE cancellation_reason IS NULL;

-- Reconcile the counts against the full table.
SELECT COUNT(*) AS total_trips,
       COUNT(*) FILTER (
           WHERE cancellation_reason != 'Rider cancelled'
       ) AS returned_by_inequality,
       COUNT(*) FILTER (
           WHERE cancellation_reason IS NULL
       ) AS omitted_because_null,
       COUNT(*) FILTER (
           WHERE cancellation_reason = 'Rider cancelled'
       ) AS excluded_reason_matches
FROM trips;

-- Include NULL reasons while still excluding "Rider cancelled".
SELECT COUNT(*) AS repaired_rows
FROM trips
WHERE cancellation_reason != 'Rider cancelled'
   OR cancellation_reason IS NULL;

--Part B. The alias that did not exist yet.
column "fare_with_10_percent_surcharge" does not exist

-- Invalid: the alias is not available to WHERE.
SELECT trip_id, fare_amount * 1.10 AS fare_with_10_percent_surcharge
FROM trips
WHERE fare_with_10_percent_surcharge > 50;

-- Repeat the expression in WHERE.
SELECT trip_id, fare_amount * 1.10 AS fare_with_10_percent_surcharge
FROM trips
WHERE fare_amount * 1.10 > 50;

-- The CTE makes the alias available as a column to the outer query.
WITH trips_with_surcharge AS (
    SELECT trip_id,
           fare_amount * 1.10 AS fare_with_10_percent_surcharge
    FROM trips
)
SELECT trip_id, fare_with_10_percent_surcharge
FROM trips_with_surcharge
WHERE fare_with_10_percent_surcharge > 50;