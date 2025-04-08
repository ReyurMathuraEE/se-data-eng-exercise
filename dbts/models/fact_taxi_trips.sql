{{ config(
    materialized='incremental',
    unique_key=['trip_id', 'pickup_location_id', 'dropoff_location_id', 'vendor_id', 'payment_type_id', 'pickup_date_id', 'dropoff_date_id'],
    tags=['taxi_trips'],
    on_schema_change = 'sync_all_columns',
    incremental_strategy = 'merge'
) }}

WITH source AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['vendor_id', 'tpep_pickup_datetime', 'pickup_longitude', 'pickup_latitude']) }} AS trip_id,
        {{ dbt_utils.generate_surrogate_key(['pickup_longitude', 'pickup_latitude']) }} AS pickup_location_id,
        {{ dbt_utils.generate_surrogate_key(['dropoff_longitude', 'dropoff_latitude']) }} AS dropoff_location_id,
        {{ dbt_utils.generate_surrogate_key(['tpep_pickup_datetime']) }} AS pickup_date_id,
        {{ dbt_utils.generate_surrogate_key(['tpep_dropoff_datetime']) }} AS dropoff_date_id,
        vendor_id,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        pickup_longitude,
        pickup_latitude,
        dropoff_longitude,
        dropoff_latitude,
        payment_type AS payment_type_id,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        total_amount,
        improvement_surcharge,
        -- Derived metrics
        DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_minutes,
        CASE
            WHEN DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) > 0 THEN
                trip_distance / (DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) / 60.0)
            ELSE NULL
        END AS trip_speed_mph,
        created_timestamp AS updated_ts

    FROM {{ ref('taxi_trips_consistent') }}
    {% if is_incremental() %}
    WHERE created_timestamp > (SELECT MAX(updated_ts) FROM {{ this }})
    {% endif %}
)

SELECT
    trip_id,
    vendor_id,
    payment_type_id,
    pickup_location_id,
    dropoff_location_id,
    pickup_date_id,
    dropoff_date_id,
    trip_distance,
    trip_duration_minutes,
    trip_speed_mph,
    tip_amount,
    tolls_amount,
    total_amount,
    extra,
    mta_tax,
    fare_amount,
    passenger_count,
    improvement_surcharge,
    updated_ts,

FROM source
