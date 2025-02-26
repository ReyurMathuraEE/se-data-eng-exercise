{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

WITH source AS (
    SELECT * FROM {{ ref('stg_taxi_trips_consistent') }}
),

validated AS (
    SELECT
        vendor_id,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        pickup_longitude,
        pickup_latitude,
        ratecode_id,
        store_and_fwd_flag,
        dropoff_longitude,
        dropoff_latitude,
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
    FROM source
)

SELECT * FROM validated
