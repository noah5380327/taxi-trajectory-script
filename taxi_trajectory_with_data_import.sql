
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Drop tables if exist (for reruns)
DROP TABLE IF EXISTS trajectory_points;
DROP TABLE IF EXISTS trajectories;

-- Create trajectories table
CREATE TABLE trajectories (
    id INTEGER PRIMARY KEY,
    taxi_id VARCHAR,
    trajectory_date DATE
);

-- Create trajectory_points table
CREATE TABLE trajectory_points (
    id INTEGER PRIMARY KEY,
    trajectory_id INTEGER REFERENCES trajectories(id) ON DELETE CASCADE,
    point GEOMETRY(POINT, 4326),
    timestamp TIMESTAMP
);

-- Drop and create temp table for point import
DROP TABLE IF EXISTS temp_points;

CREATE TEMP TABLE temp_points (
    id INTEGER,
    trajectory_id INTEGER,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    timestamp TIMESTAMP
);

-- Data import (update file paths as needed)
-- IMPORTANT: Modify the paths below to the correct absolute path before running

-- Import trajectory metadata
COPY trajectories(id, taxi_id, trajectory_date)
FROM '/absolute/path/to/trajectories_sample.csv'
DELIMITER ',' CSV HEADER;

-- Import raw point data into temporary table
COPY temp_points(id, trajectory_id, lon, lat, timestamp)
FROM '/absolute/path/to/trajectory_points_sample.csv'
DELIMITER ',' CSV HEADER;

-- Insert into trajectory_points with geometry construction
INSERT INTO trajectory_points (id, trajectory_id, point, timestamp)
SELECT id, trajectory_id, ST_SetSRID(ST_MakePoint(lon, lat), 4326), timestamp
FROM temp_points;

-- Create spatial index
CREATE INDEX idx_geom ON trajectory_points USING GIST(point);
