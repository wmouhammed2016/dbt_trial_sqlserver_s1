-- One row per surgical kit (catalog attributes only).
-- Stock levels and expiration dates change per reading,
-- so they live in fct_kit_inventory.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    surgical_kit_id,
    kit_name,
    kit_unit_cost_usd,
    kit_lead_time_days,
    kit_reorder_point

from encounters
