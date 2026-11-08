-- ED / patient-flow throughput.
-- Grain: one row per admission day x hospital unit.
-- Audience: emergency department and operations.

with

encounters as (

    select * from {{ ref('fct_encounters') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

-- SQL Server only offers PERCENTILE_CONT as a window function,
-- so medians are calculated per row first and collapsed in the next step.
with_medians as (

    select
        admitted_date,
        unit_assigned,
        door_to_admit_minutes,
        admit_to_bed_request_minutes,
        bed_boarding_minutes,
        bed_occupancy_pct,
        percentile_cont(0.5) within group (order by door_to_admit_minutes)
            over (partition by admitted_date, unit_assigned)    as median_door_to_admit_minutes,
        percentile_cont(0.5) within group (order by bed_boarding_minutes)
            over (partition by admitted_date, unit_assigned)    as median_bed_boarding_minutes
    from encounters

),

daily as (

    select
        admitted_date,
        unit_assigned,
        count(*)                                                            as encounters,
        cast(avg(door_to_admit_minutes * 1.0) as decimal(8, 1))             as avg_door_to_admit_minutes,
        cast(max(median_door_to_admit_minutes) as decimal(8, 1))            as median_door_to_admit_minutes,
        cast(avg(admit_to_bed_request_minutes * 1.0) as decimal(8, 1))      as avg_admit_to_bed_request_minutes,
        cast(avg(bed_boarding_minutes * 1.0) as decimal(8, 1))              as avg_bed_boarding_minutes,
        cast(max(median_bed_boarding_minutes) as decimal(8, 1))             as median_bed_boarding_minutes,
        cast(avg(bed_occupancy_pct) as decimal(5, 1))                       as avg_bed_occupancy_pct
    from with_medians
    group by admitted_date, unit_assigned

)

select
    daily.admitted_date                 as admission_date,
    dates.day_name,
    dates.is_weekend,
    dates.month_start_date              as admission_month,
    daily.unit_assigned                 as unit_name,
    daily.encounters,
    daily.avg_door_to_admit_minutes,
    daily.median_door_to_admit_minutes,
    daily.avg_admit_to_bed_request_minutes,
    daily.avg_bed_boarding_minutes,
    daily.median_bed_boarding_minutes,
    daily.avg_bed_occupancy_pct

from daily
inner join dates
    on dates.date_day = daily.admitted_date
