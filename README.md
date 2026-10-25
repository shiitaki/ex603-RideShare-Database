# ex603-RideShare-Database
This repository will hold a postgresql generated database for a ride share company. 

The database will include information on riders, drivers, trips, driver_badges, driver_badge_awards, and the fare_amount.

This database handles core ride-sharing transactions and a driver rewards system. It uses a structured setup to keep data clean, safe, and efficient.
1. Table Creation and Reset Order
When working with relational databases, tables with references (Foreign Keys) cannot be created or deleted randomly.
Creation Order (Top-to-Bottom)
1. riders – Independent. Stores user data. No external dependencies.
2. drivers – Independent. Stores operator profile data.
3. driver_badges – Independent. Stores the available catalog of badge names and descriptions.
4. trips – Dependent. Connects a rider and a driver together. Both must exist before a trip can happen.
5. driver_badge_awards – Dependent. A junction table linking drivers to the badges they earn. Both the driver and the badge must exist first.
Destruction Order (Reset Block)
When resetting the database, we drop tables in the exact reverse order:
driver_badge_awards ➔ trips ➔ driver_badges ➔ drivers ➔ riders
This prevents errors because you cannot delete a table (like riders) while another table (like trips) is still actively pointing to it.
2. Table Summary & Design Highlights
• riders: Tracks passengers. The email column is unique and required so users cannot register twice with the same account.
• drivers: Tracks contractors. The license number column is unique to prevent duplicate or fraudulent driver registrations.
• driver_badges: A master list of all awards a driver can get (like "Top Rated" or "Night Owl").
• trips: Records completed journeys. It uses the DECIMAL(10,2) type for fares to avoid mathematical rounding errors common with standard decimals. The trip end time can be empty (NULL) to account for rides currently in progress.
• driver_badge_awards: Records which driver earned what badge and when. It automatically sets the time using the database's internal clock (CURRENT_TIMESTAMP).
3. Key Safeguards & Rules
• Named Constraints: Every primary key (pk_), foreign key (fk_), and unique column (uq_) is explicitly named. This means if a query breaks a rule, the error message clearly tells us exactly which constraint was violated, instead of giving a generic database error code.
• Exact Type Matching: Every foreign key data type matches its primary key counterpart perfectly as an INTEGER. This ensures fast searches and prevents validation bugs.
• Smart Deletions:
	• If a rider deletes their profile, their trip history is completely wiped out (ON DELETE CASCADE).
	• If a driver leaves the company, their historical trip logs remain intact for financial auditing, but their driver connection is cleared out (ON DELETE SET NULL).


QUERY CATALOG

1. Macro Regional Performance Overview

Business Question: What is the total trip volume, driver participation, revenue, average fare, distance, and failure rate for each pickup city?

SELECT 
    pickup_city AS region,
    COUNT(trip_id) AS total_events,
    COUNT(DISTINCT driver_id) AS active_producers_count,
    ROUND(SUM(fare_amount), 2) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) AS failed_trips_count,
    ROUND(SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) * 100.0 / COUNT(trip_id), 2) AS failure_rate_pct
FROM trips
GROUP BY pickup_city
ORDER BY total_revenue DESC;


2. Multi-Dimensional Performance (Region × Producer)

Business Question: How is driver activity, revenue generation, and cancellation volume distributed across regional markets?

SELECT 
    pickup_city AS region,
    driver_id AS producer_id,
    COUNT(trip_id) AS event_count,
    ROUND(SUM(fare_amount), 2) AS total_revenue,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) AS failed_trips_count
FROM trips
GROUP BY pickup_city, driver_id
ORDER BY region, event_count DESC;


3. Task 4.2 Part A: Single-Pass Conditional Aggregation

Business Question: What is each producer's total event volume alongside their specific count of failed or cancelled events in a single database pass?

SELECT 
    driver_id AS producer_id,
    COUNT(trip_id) AS total_events,
    SUM(CASE WHEN trip_status IN ('cancelled', 'disputed') THEN 1 ELSE 0 END) AS failure_count
FROM trips
GROUP BY driver_id
ORDER BY total_events DESC;


4. Task 4.2 Part B: Regional Rollups and Platform Grand Total

Business Question: What are the subtotal event counts and total revenues for each region, alongside the platform-wide grand total?

SELECT 
    COALESCE(pickup_city, 'GRAND TOTAL') AS region,
    COUNT(trip_id) AS total_events,
    ROUND(SUM(fare_amount), 2) AS total_revenue
FROM trips
GROUP BY ROLLUP(pickup_city)
ORDER BY pickup_city NULLS LAST;


5. Task 4.2 Part C: High-Volume Producer Baseline Pipeline

Business Question: What is the baseline performance benchmark among high-volume producers meeting the minimum activity threshold (>= 10 trips)?

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


