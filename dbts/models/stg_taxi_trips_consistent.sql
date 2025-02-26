{{ config(
    materialized='incremental',
    unique_key='created_timestamp',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
) }}

WITH source AS (
    SELECT
        vendor_name AS vendor_id,
        tpep_pickup_datetime::timestamp AS tpep_pickup_datetime,
        tpep_dropoff_datetime::timestamp AS tpep_dropoff_datetime,
        passenger_count::number(3, 0) AS passenger_count,
        trip_distance::number(10, 2) AS trip_distance,
        pickup_longitude::number(18, 15) AS pickup_longitude,
        pickup_latitude::number(18, 15) AS pickup_latitude,
        RatecodeID::number(3, 0) AS ratecode_id,
        store_and_fwd_flag,
        dropoff_longitude::number(18, 15) AS dropoff_longitude,
        dropoff_latitude::number(18, 15) AS dropoff_latitude,
        payment_type::number(3, 0) AS payment_type,
        payment_type_name,
        fare_amount::number(10, 2) AS fare_amount,
        extra::number(10, 2) AS extra,
        mta_tax::number(10, 2) AS mta_tax,
        tip_amount::number(10, 2) AS tip_amount,
        tolls_amount::number(10, 2) AS tolls_amount,
        improvement_surcharge::number(10, 2) AS improvement_surcharge,
        total_amount::number(10, 2) AS total_amount,
        CURRENT_TIMESTAMP::TIMESTAMP_NTZ(9) AS created_timestamp
    FROM {{ source('snowflake', 'TAXI_TRIPS_RAW') }}
),

avg_passenger_count AS (
    SELECT AVG(passenger_count) AS avg_passenger_count
    FROM {{ source('snowflake', 'TAXI_TRIPS_RAW') }}
    WHERE passenger_count > 0
),

cleaned AS (
    SELECT
        COALESCE(vendor_id, 1) AS vendor_id,

        -- Handle pickup datetime
        CASE
            WHEN tpep_pickup_datetime IS NULL AND tpep_dropoff_datetime IS NOT NULL AND trip_distance > 0
            THEN DATEADD(minute, -1 * ((trip_distance / 12) * 60), tpep_dropoff_datetime)
            ELSE COALESCE(tpep_pickup_datetime, TO_TIMESTAMP('1900-01-01 00:00:00'))
        END AS tpep_pickup_datetime,

        -- Handle dropoff datetime
        CASE
            WHEN tpep_dropoff_datetime IS NULL AND tpep_pickup_datetime IS NOT NULL AND trip_distance > 0
            THEN DATEADD(minute, ((trip_distance / 12) * 60), tpep_pickup_datetime)
            ELSE COALESCE(tpep_dropoff_datetime, TO_TIMESTAMP('1900-01-01 00:00:00'))
        END AS tpep_dropoff_datetime,

        -- Calculate trip_distance if zero
        CASE
            WHEN trip_distance = 0
                AND pickup_latitude IS NOT NULL AND pickup_longitude IS NOT NULL
                AND dropoff_latitude IS NOT NULL AND dropoff_longitude IS NOT NULL
                AND (pickup_latitude != dropoff_latitude OR pickup_longitude != dropoff_longitude)
            THEN 3959 * ACOS(
                COS(RADIANS(pickup_latitude)) * COS(RADIANS(dropoff_latitude)) *
                COS(RADIANS(dropoff_longitude) - RADIANS(pickup_longitude)) +
                SIN(RADIANS(pickup_latitude)) * SIN(RADIANS(dropoff_latitude))
            )
            ELSE trip_distance
        END AS trip_distance,

        -- Replace zero passenger_count with historical average
        CASE
            WHEN passenger_count = 0 THEN (SELECT avg_passenger_count FROM avg_passenger_count)
            ELSE passenger_count
        END AS passenger_count,

        -- Replace zero coordinates with JFK Airport coordinates
        CASE
            WHEN pickup_longitude = 0 OR pickup_longitude IS NULL THEN -73.7781
            ELSE pickup_longitude
        END AS pickup_longitude,

        CASE
            WHEN pickup_latitude = 0 OR pickup_latitude IS NULL THEN 40.6413
            ELSE pickup_latitude
        END AS pickup_latitude,

        dropoff_longitude,
        dropoff_latitude,
        ratecode_id,
        store_and_fwd_flag,
        payment_type,
        payment_type_name,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        created_timestamp
    FROM source, avg_passenger_count
    WHERE NOT (
        (vendor_id IS NULL OR vendor_id = 0) OR
        (tpep_pickup_datetime IS NULL) OR
        (tpep_dropoff_datetime IS NULL) OR
        (pickup_longitude IS NULL OR pickup_longitude = 0) OR
        (pickup_latitude IS NULL OR pickup_latitude = 0) OR
        (dropoff_longitude IS NULL OR dropoff_longitude = 0) OR
        (dropoff_latitude IS NULL OR dropoff_latitude = 0) OR
        (tpep_dropoff_datetime < tpep_pickup_datetime)
    )
),

-- Remove duplicate rows, keeping the latest based on created_timestamp
deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY vendor_id, tpep_pickup_datetime, pickup_longitude, pickup_latitude
               ORDER BY created_timestamp DESC
           ) AS row_num
    FROM cleaned
)

SELECT * FROM deduplicated WHERE row_num = 1
