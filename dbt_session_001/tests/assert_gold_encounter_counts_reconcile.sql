-- Every encounter must be counted exactly once in each encounter-based gold mart.
-- Returns one row per mart whose total does not match fct_encounters.

with silver as (

    select count(*) as encounters from {{ ref('fct_encounters') }}

),

gold as (

    select 'mart_ed_throughput_daily' as mart_name, sum(encounters) as encounters
    from {{ ref('mart_ed_throughput_daily') }}
    union all
    select 'mart_unit_scorecard_monthly', sum(encounters)
    from {{ ref('mart_unit_scorecard_monthly') }}
    union all
    select 'mart_clinical_quality_monthly', sum(encounters)
    from {{ ref('mart_clinical_quality_monthly') }}
    union all
    select 'mart_or_utilization_weekly', sum(cases)
    from {{ ref('mart_or_utilization_weekly') }}

)

select
    gold.mart_name,
    gold.encounters     as gold_encounters,
    silver.encounters   as silver_encounters
from gold
cross join silver
where gold.encounters <> silver.encounters
