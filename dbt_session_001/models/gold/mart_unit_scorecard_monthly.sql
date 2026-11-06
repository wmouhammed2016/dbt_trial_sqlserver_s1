-- Unit scorecard: volume, safety, patient experience, staffing and outcomes.
-- Grain: one row per admission month x hospital unit (the unit where care happened).
-- Audience: unit managers and nursing leadership.
-- Rates are stored with their numerator and denominator so they can be
-- re-aggregated correctly (e.g. month -> year).

with

encounters as (

    select * from {{ ref('fct_encounters') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

nurses as (

    select * from {{ ref('dim_nurse') }}

),

encounters_by_month as (

    select
        dates.month_start_date      as admission_month,
        encounters.*
    from encounters
    inner join dates
        on dates.date_day = encounters.admitted_date

),

unit_month as (

    select
        admission_month,
        unit_assigned,

        -- volume
        count(*)                                                                as encounters,
        cast(sum(los_hours) / 24.0 as decimal(10, 1))                           as patient_days,

        -- safety
        sum(cast(has_safety_incident as int))                                   as safety_incidents,
        sum(case when incident_severity = 'Major' then 1 else 0 end)            as incidents_major,
        sum(case when incident_severity = 'Moderate' then 1 else 0 end)         as incidents_moderate,
        sum(case when incident_severity = 'Minor' then 1 else 0 end)            as incidents_minor,
        sum(case when incident_severity = 'Near-Miss' then 1 else 0 end)        as incidents_near_miss,

        -- outcomes
        sum(cast(is_readmitted_30d as int))                                     as readmissions_30d,

        -- patient experience (CAHPS, 1-5)
        cast(avg(cahps_nurse_communication) as decimal(3, 2))                   as avg_cahps_nurse_communication,
        cast(avg(cahps_doctor_communication) as decimal(3, 2))                  as avg_cahps_doctor_communication,
        cast(avg(cahps_responsiveness) as decimal(3, 2))                        as avg_cahps_responsiveness,
        cast(avg(cahps_pain_management) as decimal(3, 2))                       as avg_cahps_pain_management,
        cast(avg(cahps_discharge_info) as decimal(3, 2))                        as avg_cahps_discharge_info,
        cast(avg(cahps_care_transition) as decimal(3, 2))                       as avg_cahps_care_transition,
        cast(avg(cahps_cleanliness) as decimal(3, 2))                           as avg_cahps_cleanliness,
        cast(avg(cahps_quietness) as decimal(3, 2))                             as avg_cahps_quietness,
        cast(avg(cahps_composite_score) as decimal(3, 2))                       as avg_cahps_composite_score,

        -- staffing (shift level, encounter weighted)
        count(distinct nurse_emp_id)                                            as distinct_nurses,
        cast(avg(patients_per_nurse_ratio * 1.0) as decimal(4, 2))              as avg_patients_per_nurse,
        cast(avg(shift_hours * 1.0) as decimal(4, 2))                           as avg_shift_hours,
        cast(avg(overtime_hours) as decimal(4, 2))                              as avg_overtime_hours,
        cast(avg(turnover_risk_index) as decimal(4, 3))                         as avg_turnover_risk_index

    from encounters_by_month
    group by admission_month, unit_assigned

),

-- Burnout is a nurse attribute: average it over the distinct nurses who
-- worked in the unit that month, not over encounters.
nurse_burnout as (

    select
        worked.admission_month,
        worked.unit_assigned,
        cast(avg(nurses.burnout_exhaustion_mbi) as decimal(3, 2))               as avg_nurse_burnout_exhaustion,
        cast(avg(nurses.burnout_cynicism_mbi) as decimal(3, 2))                 as avg_nurse_burnout_cynicism,
        cast(avg(nurses.burnout_personal_accomplishment_mbi) as decimal(3, 2))  as avg_nurse_personal_accomplishment
    from (
        select distinct admission_month, unit_assigned, nurse_emp_id
        from encounters_by_month
    ) as worked
    inner join nurses
        on nurses.nurse_emp_id = worked.nurse_emp_id
    group by worked.admission_month, worked.unit_assigned

)

select
    unit_month.admission_month,
    unit_month.unit_assigned                                                    as unit_name,

    -- volume
    unit_month.encounters,
    unit_month.patient_days,

    -- safety
    unit_month.safety_incidents,
    cast(unit_month.safety_incidents * 1000.0
         / nullif(unit_month.patient_days, 0) as decimal(8, 2))                 as incidents_per_1000_patient_days,
    unit_month.incidents_major,
    unit_month.incidents_moderate,
    unit_month.incidents_minor,
    unit_month.incidents_near_miss,

    -- outcomes
    unit_month.readmissions_30d,
    cast(unit_month.readmissions_30d * 1.0
         / nullif(unit_month.encounters, 0) as decimal(5, 4))                   as readmission_rate_30d,

    -- patient experience
    unit_month.avg_cahps_nurse_communication,
    unit_month.avg_cahps_doctor_communication,
    unit_month.avg_cahps_responsiveness,
    unit_month.avg_cahps_pain_management,
    unit_month.avg_cahps_discharge_info,
    unit_month.avg_cahps_care_transition,
    unit_month.avg_cahps_cleanliness,
    unit_month.avg_cahps_quietness,
    unit_month.avg_cahps_composite_score,

    -- staffing
    unit_month.distinct_nurses,
    unit_month.avg_patients_per_nurse,
    unit_month.avg_shift_hours,
    unit_month.avg_overtime_hours,
    unit_month.avg_turnover_risk_index,
    nurse_burnout.avg_nurse_burnout_exhaustion,
    nurse_burnout.avg_nurse_burnout_cynicism,
    nurse_burnout.avg_nurse_personal_accomplishment

from unit_month
inner join nurse_burnout
    on  nurse_burnout.admission_month = unit_month.admission_month
    and nurse_burnout.unit_assigned   = unit_month.unit_assigned
