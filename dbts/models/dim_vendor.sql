{{ config(
    materialized='incremental',
    unique_key='vendor_id',
    tags=['taxi_trips']
) }}

WITH source AS (
    SELECT DISTINCT
        vendor_id AS vendor_id,
        CASE
            WHEN vendor_id = '1.00000' THEN 'Creative Mobile Technologies, LLC'
            WHEN vendor_id = '2.00000' THEN 'VeriFone Inc'
            ELSE 'Unknown Vendor'
        END AS vendor_name,

        created_timestamp AS updated_ts
    FROM {{ ref('taxi_trips_consistent') }}

    {% if is_incremental() %}
    WHERE created_timestamp > (SELECT MAX(updated_ts) FROM {{ this }})
    {% endif %}
)

SELECT
    vendor_id,
    vendor_name,
    updated_ts
FROM source