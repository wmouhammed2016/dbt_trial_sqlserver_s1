-- mart_kit_stockout_status must have exactly one row for every kit in dim_surgical_kit.
-- Returns kits that are missing from the mart.

select kits.surgical_kit_id
from {{ ref('dim_surgical_kit') }} as kits
left join {{ ref('mart_kit_stockout_status') }} as status
    on status.surgical_kit_id = kits.surgical_kit_id
where status.surgical_kit_id is null
