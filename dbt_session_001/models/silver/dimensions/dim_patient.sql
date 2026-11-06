-- One row per patient.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select distinct
    patient_id,
    birth_year,
    age,
    case
        when age < 35 then '18-34'
        when age < 50 then '35-49'
        when age < 65 then '50-64'
        when age < 80 then '65-79'
        else '80+'
    end                                 as age_band,
    sex,
    race_ethnicity,
    patient_state

from encounters
