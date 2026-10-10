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

-- POSITION 1: Riders Table
-- Why here: Independent entity with no foreign key dependencies. 
CREATE TABLE riders (
    rider_id INTEGER,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,

    -- Named Constraints
    CONSTRAINT pk_riders PRIMARY KEY (rider_id),
    CONSTRAINT uq_riders_email UNIQUE (email)
);

-- POSITION 2: Drivers Table
-- Why here: Independent entity with no foreign key dependencies.
CREATE TABLE drivers (
    driver_id INTEGER,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL,

    -- Named Constraints
    CONSTRAINT pk_drivers PRIMARY KEY (driver_id),
    CONSTRAINT uq_drivers_license UNIQUE (license_number)
);

-- POSITION 3: Driver Badges Table
-- Why here: Independent lookup table with no foreign key dependencies.
CREATE TABLE driver_badges (
    badge_id INTEGER,
    badge_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),

    -- Named Constraints
    CONSTRAINT pk_driver_badges PRIMARY KEY (badge_id)
);

-- POSITION 4: Trips Table
-- Why here: Dependent entity; references rider_id (Riders) and driver_id (Drivers) which must exist first.
CREATE TABLE trips (
    trip_id INTEGER,
    rider_id INTEGER NOT NULL, -- Matches INTEGER type from riders exactly
    driver_id INTEGER,         -- Matches INTEGER type from drivers exactly
    fare_amount DECIMAL(10, 2) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,

    -- Named Constraints
    CONSTRAINT pk_trips PRIMARY KEY (trip_id),
    CONSTRAINT fk_trips_riders FOREIGN KEY (rider_id) REFERENCES riders(rider_id) ON DELETE CASCADE,
    CONSTRAINT fk_trips_drivers FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE SET NULL
);

-- POSITION 5: Driver Badge Awards Table
-- Why here: Dependent junction table; references driver_id (Drivers) and badge_id (Driver Badges) which must exist first.
CREATE TABLE driver_badge_awards (
    award_id INTEGER,
    driver_id INTEGER NOT NULL, -- Matches INTEGER type from drivers exactly
    badge_id INTEGER NOT NULL,  -- Matches INTEGER type from driver_badges exactly
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Named Constraints
    CONSTRAINT pk_driver_badge_awards PRIMARY KEY (award_id),
    CONSTRAINT fk_driver_badge_awards_drivers FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE CASCADE,
    CONSTRAINT fk_driver_badge_awards_badges FOREIGN KEY (badge_id) REFERENCES driver_badges(badge_id) ON DELETE CASCADE
);
