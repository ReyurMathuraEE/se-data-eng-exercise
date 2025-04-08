{{ config(
    materialized='incremental',
    unique_key='payment_type_id',
    tags=['taxi_trips']
) }}

WITH source AS (
    SELECT DISTINCT
        payment_type AS payment_type_id,
        CASE
            WHEN payment_type_id = '1' THEN 'Credit card'
            WHEN payment_type_id = '2' THEN 'Cash'
            WHEN payment_type_id = '3' THEN 'No charge'
            WHEN payment_type_id = '4' THEN 'Dispute'
            WHEN payment_type_id = '5' THEN 'Unknown'
            WHEN payment_type_id = '6' THEN 'Voided trip'
            ELSE 'Unknown Payment'
        END AS payment_type_name,
        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}
    {% if is_incremental() %}
    WHERE updated_ts > (SELECT MAX(updated_ts) FROM {{ this }})
    {% endif %}
)

SELECT
    payment_type_id,
    payment_type_name,
    updated_ts
FROM source
