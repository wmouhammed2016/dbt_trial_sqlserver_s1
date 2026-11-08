-- Surgical kit stockout status, based on each kit's latest stock reading.
-- Grain: one row per surgical kit.
-- Audience: supply chain.

with

readings as (

    select * from {{ ref('fct_kit_inventory') }}

),

kits as (

    select * from {{ ref('dim_surgical_kit') }}

),

latest_reading as (

    select
        readings.*,
        row_number() over (
            partition by surgical_kit_id
            order by reading_at desc, encounter_id desc     -- tie-breaker keeps it deterministic
        ) as reading_rank
    from readings

)

select
    kits.surgical_kit_id,
    kits.kit_name,
    latest_reading.reading_at                                           as latest_reading_at,

    -- stock position
    latest_reading.kit_current_stock                                    as current_stock,
    kits.kit_reorder_point                                              as reorder_point,
    kits.kit_lead_time_days                                             as lead_time_days,
    latest_reading.weekly_procedure_volume,
    latest_reading.projected_demand_4wk,
    latest_reading.days_of_supply,
    latest_reading.is_stockout_risk,
    cast(case when latest_reading.days_of_supply < kits.kit_lead_time_days
              then 1 else 0 end as bit)                                 as runs_out_before_resupply,

    -- value & expiry
    kits.kit_unit_cost_usd                                              as unit_cost_usd,
    cast(latest_reading.kit_current_stock * kits.kit_unit_cost_usd
         as decimal(12, 2))                                             as stock_value_usd,
    latest_reading.kit_expiration_date,
    datediff(day, latest_reading.reading_date,
             latest_reading.kit_expiration_date)                        as days_until_expiration

from kits
inner join latest_reading
    on  latest_reading.surgical_kit_id = kits.surgical_kit_id
    and latest_reading.reading_rank = 1
