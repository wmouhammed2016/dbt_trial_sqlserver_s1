-- One row per nurse.
-- Only attributes that are stable per nurse belong here.
-- Shift-level values (shift hours, patients per nurse, overtime, turnover risk)
-- change from encounter to encounter, so they live in fct_encounters.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    nurse_emp_id,
    nurse_role,
    nurse_unit,
    nurse_tenure_years,
    nurse_fte,
    burnout_exhaustion_mbi,
    burnout_cynicism_mbi,
    burnout_personal_accomplishment_mbi

from encounters
