-- What's the total number of rides that took place everyday for first 5 days
SELECT
    time_bucket('1 DAY', pickup_datetime) AS DAY,
    COUNT(*)
FROM
    rides
GROUP BY
    DAY
ORDER BY
    DAY;

-- What is the daily average fare amount for rides with only one passenger
-- for first 7 days?
SELECT
    time_bucket('1 day', pickup_datetime) AS DAY,
    avg(fare_amount)
FROM
    rides
WHERE
    passenger_count = 1
    AND pickup_datetime < '2016-01-08'
GROUP BY
    DAY
ORDER BY
    DAY;
    
-- How many rides of each rate type took place in the month?
SELECT
    rate_code,
    COUNT(vendor_id) AS num_trips
FROM
    rides
WHERE
    pickup_datetime < '2016-02-01'
GROUP BY
    rate_code
ORDER BY
    rate_code;
    
-- How many rides of each rate type took place?
-- Join rides with rates to get more information on rate_code
SELECT
    rates.description,
    COUNT(vendor_id) AS num_trips,
    RANK () OVER (ORDER BY COUNT(vendor_id) DESC) AS trip_rank
FROM
    rides
JOIN rates ON
    rides.rate_code = rates.rate_code
WHERE
    pickup_datetime < '2016-02-01'
GROUP BY
    rates.description
ORDER BY
    LOWER(rates.description);
    
-- For each airport: num trips, avg trip duration, avg cost, avg tip, avg distance,
-- min distance, max distance, avg number of passengers
SELECT
    rates.description,
    COUNT(vendor_id) AS num_trips,
    AVG(dropoff_datetime - pickup_datetime) AS avg_trip_duration,
    AVG(total_amount) AS avg_total,
    AVG(tip_amount) AS avg_tip,
    MIN(trip_distance) AS min_distance,
    AVG (trip_distance) AS avg_distance,
    MAX(trip_distance) AS max_distance,
    AVG(passenger_count) AS avg_passengers
FROM
    rides
JOIN rates ON
    rides.rate_code = rates.rate_code
WHERE
    rides.rate_code IN (2, 3)
    AND pickup_datetime < '2016-02-01'
GROUP BY
    rates.description
ORDER BY
    rates.description;
    
-- Vanilla Postgres query for num rides every 5 minutes
SELECT
    EXTRACT(HOUR
FROM
    pickup_datetime) AS hours,
    trunc(EXTRACT(MINUTE FROM pickup_datetime) / 5)* 5 AS five_mins,
    COUNT(*)
FROM
    rides
WHERE
    pickup_datetime < '2016-01-02 00:00'
GROUP BY
    hours,
    five_mins;
    
-- How many rides took place every 5 minutes for the first day of 2016?
-- using the TimescaleDB "time_bucket" function
SELECT
    time_bucket('5 minute', pickup_datetime) AS five_min,
    count(*)
FROM
    rides
WHERE
    pickup_datetime < '2016-01-02 00:00'
GROUP BY
    five_min
ORDER BY
    five_min;
    
-- How many taxis pick up rides within 400m of Times Square on New Years Day, grouped by 30 minute buckets.
-- Number of rides on New Years Day originating within 400m of Times Square, by 30 min buckets
-- Note: Times Square is at (lat, long) (40.7589,-73.9851)
SELECT
    time_bucket('30 minutes', pickup_datetime) AS thirty_min,
    COUNT(*) AS near_times_sq
FROM
    rides
WHERE
    ST_Distance(pickup_geom,
    ST_Transform(ST_SetSRID(ST_MakePoint(-73.9851,
    40.7589),
    4326),
    2163)) < 400
    AND pickup_datetime < '2016-01-01 14:00'
GROUP BY
    thirty_min
ORDER BY
    thirty_min;
    

SELECT * FROM rides r LIMIT 10;
SELECT
    distinct_count(passenger_count)
FROM
    rides;