-- Operating room utilization.
-- Grain: one row per surgery week (Monday start) x surgeon specialty.
-- Audience: surgical services.

with

encounters as (

    select * from {{ ref('fct_encounters') }}

),

surgeons as (

    select * from {{ ref('dim_surgeon') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

surgeries as (

    select
        dates.week_start_date           as surgery_week_start,
        surgeons.surgeon_specialty,
        encounters.surgeon_emp_id,
        encounters.actual_or_minutes,
        encounters.or_turnover_minutes
    from encounters
    inner join surgeons
        on surgeons.surgeon_emp_id = encounters.surgeon_emp_id
    inner join dates
        on dates.date_day = cast(encounters.or_started_at as date)

),

-- PERCENTILE_CONT is window-only in SQL Server: compute per row, collapse below.
with_medians as (

    select
        surgeries.*,
        percentile_cont(0.5) within group (order by actual_or_minutes)
            over (partition by surgery_week_start, surgeon_specialty)   as median_or_minutes
    from surgeries

)

select
    surgery_week_start,
    surgeon_specialty                                                   as specialty,
    count(*)                                                            as cases,
    count(distinct surgeon_emp_id)                                      as distinct_surgeons,
    sum(actual_or_minutes)                                              as total_or_minutes,
    cast(avg(actual_or_minutes * 1.0) as decimal(6, 1))                 as avg_or_minutes,
    cast(max(median_or_minutes) as decimal(6, 1))                       as median_or_minutes,
    cast(avg(or_turnover_minutes * 1.0) as decimal(6, 1))               as avg_turnover_minutes,
    cast(sum(actual_or_minutes) / 60.0
         / count(distinct surgeon_emp_id) as decimal(6, 2))             as or_hours_per_surgeon

from with_medians
group by surgery_week_start, surgeon_specialty
