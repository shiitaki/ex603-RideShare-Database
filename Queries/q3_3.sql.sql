SELECT d.driver_id, d.driver_name
FROM drivers AS d
WHERE d.driver_id IN (
    SELECT t.driver_id
    FROM trips AS t
    WHERE t.trip_status = 'disputed'
)
ORDER BY d.driver_id;

WITH disputed_driver_ids AS (
    SELECT DISTINCT driver_id
    FROM trips
    WHERE trip_status = 'disputed'
)
SELECT d.driver_id, d.driver_name
FROM drivers AS d
JOIN disputed_driver_ids AS disputed
    ON disputed.driver_id = d.driver_id
ORDER BY d.driver_id;

SELECT DISTINCT d.driver_id, d.driver_name
FROM trips AS t
JOIN drivers AS d
    ON d.driver_id = t.driver_id
WHERE t.trip_status = 'disputed'
ORDER BY d.driver_id;