-- Clinical quality: readmissions and HEDIS diabetes care (HbA1c).
-- Grain: one row per admission month x diagnosis category.
-- Audience: quality team.
-- HEDIS denominator = diabetic encounters. Poor control = HbA1c > 9% (lower is better).

with

encounters as (

    select * from {{ ref('fct_encounters') }}

),

diagnoses as (

    select * from {{ ref('dim_diagnosis') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

monthly as (

    select
        dates.month_start_date                                          as admission_month,
        diagnoses.diagnosis_category,

        count(*)                                                        as encounters,
        sum(cast(encounters.is_readmitted_30d as int))                  as readmissions_30d,
        cast(avg(encounters.severity_index) as decimal(4, 3))           as avg_severity_index,
        cast(avg(encounters.los_hours) as decimal(7, 2))                as avg_los_hours,

        sum(cast(encounters.has_diabetes as int))                       as diabetic_encounters,
        sum(cast(encounters.is_hedis_hba1c_tested as int))              as hba1c_tested,
        sum(cast(encounters.is_hedis_hba1c_poor_control as int))        as hba1c_poor_control

    from encounters
    inner join diagnoses
        on diagnoses.icd10_code = encounters.icd10_code
    inner join dates
        on dates.date_day = encounters.admitted_date
    group by dates.month_start_date, diagnoses.diagnosis_category

)

select
    admission_month,
    diagnosis_category,

    encounters,
    readmissions_30d,
    cast(readmissions_30d * 1.0 / encounters as decimal(5, 4))              as readmission_rate_30d,
    avg_severity_index,
    avg_los_hours,

    diabetic_encounters,
    hba1c_tested,
    cast(hba1c_tested * 1.0 / nullif(diabetic_encounters, 0) as decimal(5, 4))       as hba1c_testing_rate,
    hba1c_poor_control,
    cast(hba1c_poor_control * 1.0 / nullif(diabetic_encounters, 0) as decimal(5, 4)) as hba1c_poor_control_rate

from monthly
