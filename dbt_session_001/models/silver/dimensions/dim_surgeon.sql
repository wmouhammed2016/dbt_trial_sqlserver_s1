-- One row per surgeon.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    surgeon_emp_id,
    surgeon_specialty

from encounters
