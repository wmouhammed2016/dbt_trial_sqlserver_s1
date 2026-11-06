-- One row per CPT procedure code.
-- Each procedure always uses the same surgical kit.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    cpt_code,
    procedure_display,
    surgical_kit_id

from encounters
