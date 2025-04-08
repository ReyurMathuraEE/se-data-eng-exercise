{{ config(
    materialized='view',
    tags=['taxi_trips', 'trip_growth_analysis']
) }}

WITH weekly_trip_volume AS (
    SELECT
        -- Use the pre-existing week, month, and year from dim_date
        d.year,
        d.month,
        d.week AS week,
        COUNT(*) AS total_trips
    FROM {{ ref('fact_taxi_trips') }} ft
    JOIN {{ ref('dim_date') }} d
        ON ft.pickup_date_id = d.date_id
    GROUP BY d.year, d.month, d.week
),

week_over_week_growth AS (
    SELECT
        year,
        month,
        week,
        total_trips,
        -- Calculate the previous week's total trips
        -- LAG(): Gets the number of trips from the previous row (previous week)
        -- PARTITION BY year: Resets the LAG calculation for each year (so weeks don't roll over from one year to the next)
        -- ORDER BY week: Ensures weeks are in order, so LAG fetches the previous week's value
        LAG(total_trips) OVER (PARTITION BY year ORDER BY week) AS previous_week_total_trips,
        -- Calculate WoW growth rate
        ((total_trips - previous_week_total_trips)
        / previous_week_total_trips) * 100 AS wow_growth_percentage
    FROM weekly_trip_volume
)

SELECT
    year,
    month,
    week,
    total_trips,
    wow_growth_percentage
FROM week_over_week_growth
