-- Every silver fact is built at the encounter grain, so each one must have
-- exactly as many rows as stg_encounters. Returns one row per fact that does not.

with staging as (

    select count(*) as row_count from {{ ref('stg_encounters') }}

),

facts as (

    select 'fct_encounters' as model_name, count(*) as row_count from {{ ref('fct_encounters') }}
    union all
    select 'fct_claims', count(*) from {{ ref('fct_claims') }}
    union all
    select 'fct_kit_inventory', count(*) from {{ ref('fct_kit_inventory') }}

)

select
    facts.model_name,
    facts.row_count     as fact_rows,
    staging.row_count   as staging_rows
from facts
cross join staging
where facts.row_count <> staging.row_count
