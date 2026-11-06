-- One row per insurance claim (one claim per encounter).

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select
    -- keys
    claim_id,
    encounter_id,
    patient_id,
    cast(discharged_at as date)                                         as claim_date,   -- claims are billed at discharge

    -- claim attributes
    payer,
    npi_billing,
    drg_weight,

    -- amounts
    submitted_charge_usd,
    allowed_amount_usd,
    patient_responsibility_usd,
    allowed_amount_usd - patient_responsibility_usd                     as payer_paid_usd,
    cast(allowed_amount_usd / nullif(submitted_charge_usd, 0)
         as decimal(6, 4))                                              as allowed_to_submitted_ratio,

    -- fraud flags
    is_fraud_upcoding,
    is_fraud_duplicate,
    is_fraud_unbundling,
    cast(is_fraud_upcoding as int)
      + cast(is_fraud_duplicate as int)
      + cast(is_fraud_unbundling as int)                                as fraud_flag_count,
    cast(case when is_fraud_upcoding = 1
                or is_fraud_duplicate = 1
                or is_fraud_unbundling = 1
              then 1 else 0 end as bit)                                 as has_any_fraud_flag

from encounters
