-- One row per surgical kit stock reading, taken at surgery time.
-- Stock is NOT a daily snapshot: it differs between surgeries on the same day.
-- For the current status of a kit, take its latest reading.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select
    -- keys
    encounter_id,
    surgical_kit_id,
    or_started_at                       as reading_at,
    cast(or_started_at as date)         as reading_date,

    -- inventory measures
    kit_current_stock,
    weekly_procedure_volume,
    projected_demand_4wk,
    days_of_supply,
    kit_expiration_date,
    is_stockout_risk

from encounters
