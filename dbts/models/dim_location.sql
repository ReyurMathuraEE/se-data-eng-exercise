{{ config(
    materialized='incremental',
    unique_key='location_id',
    tags=['taxi_trips']
) }}

WITH source AS (
    SELECT DISTINCT
        pickup_latitude AS latitude,
        pickup_longitude AS longitude,
        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}
    UNION
    SELECT DISTINCT
        dropoff_latitude AS latitude,
        dropoff_longitude AS longitude,
        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}
    {% if is_incremental() %}
    WHERE updated_ts > (SELECT MAX(updated_ts) FROM {{ this }})
    {% endif %}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['latitude', 'longitude']) }} AS location_id,
    latitude,
    longitude,
    updated_ts
FROM source
