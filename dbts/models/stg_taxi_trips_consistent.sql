{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

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
    created_timestamp
FROM {{ source('snowflake', 'TAXI_TRIPS_RAW') }}