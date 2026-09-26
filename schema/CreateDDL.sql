------------------------------------------------------------
-- STEP 2: RESET BLOCK (Drops tables in reverse order)
------------------------------------------------------------
DROP TABLE IF EXISTS driver_badge_awards CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS driver_badges CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS riders CASCADE;


------------------------------------------------------------
-- STEP 3: CREATE TABLES BLOCK
------------------------------------------------------------

-- 1. Create Riders Table
CREATE TABLE riders (
    rider_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- 2. Create Drivers Table
CREATE TABLE drivers (
    driver_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL
);

-- 3. Create Driver Badges Table
CREATE TABLE driver_badges (
    badge_id INTEGER PRIMARY KEY,
    badge_name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

-- 4. Create Trips Table
CREATE TABLE trips (
    trip_id INTEGER PRIMARY KEY,
    rider_id INTEGER REFERENCES riders(rider_id) ON DELETE CASCADE,
    driver_id INTEGER REFERENCES drivers(driver_id) ON DELETE SET NULL,
    fare_amount DECIMAL(10, 2) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP
);

-- 5. Create Driver Badge Awards Table
CREATE TABLE driver_badge_awards (
    award_id INTEGER PRIMARY KEY,
    driver_id INTEGER REFERENCES drivers(driver_id) ON DELETE CASCADE,
    badge_id INTEGER REFERENCES driver_badges(badge_id) ON DELETE CASCADE,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
