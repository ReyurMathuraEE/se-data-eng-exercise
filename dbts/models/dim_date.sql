{{ config(
    materialized='incremental',
    unique_key='date_id',
    tags=['taxi_trips']
) }}

WITH source AS (
    SELECT DISTINCT
        tpep_pickup_datetime AS date,
        EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
        EXTRACT(MONTH FROM tpep_pickup_datetime) AS month,
        EXTRACT(WEEK FROM tpep_pickup_datetime) AS week,
        EXTRACT(WEEK FROM tpep_pickup_datetime) AS week_of_the_year,
        EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime) AS day_of_week,
        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}
    UNION
    SELECT DISTINCT
        tpep_dropoff_datetime AS date,
        EXTRACT(YEAR FROM tpep_dropoff_datetime) AS year,
        EXTRACT(MONTH FROM tpep_dropoff_datetime) AS month,
        EXTRACT(WEEK FROM tpep_dropoff_datetime) AS week,
        EXTRACT(WEEK FROM tpep_dropoff_datetime) AS week_of_the_year,
        EXTRACT(DAYOFWEEK FROM tpep_dropoff_datetime) AS day_of_week,
        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}
    {% if is_incremental() %}
    WHERE updated_ts > (SELECT MAX(updated_ts) FROM {{ this }})
    {% endif %}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['date']) }} AS date_id,
    date,
    year,
    month,
    week,
    week_of_the_year,
    day_of_week,
    updated_ts
FROM source
