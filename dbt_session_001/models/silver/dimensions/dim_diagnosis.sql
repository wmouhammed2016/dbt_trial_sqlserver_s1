-- One row per ICD-10 diagnosis code.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    icd10_code,
    diagnosis_display,
    diagnosis_category

from encounters
