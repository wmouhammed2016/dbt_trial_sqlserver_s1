-- Revenue cycle and fraud monitoring.
-- Grain: one row per claim month (discharge month) x payer.
-- Audience: finance and compliance.
-- is_partial_month = 1 for months after the last admission month: they only
-- contain claims for patients admitted earlier and discharged later
-- (e.g. January 2025), so they are not comparable to full months.

with

claims as (

    select * from {{ ref('fct_claims') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

last_admission_month as (

    select max(dates.month_start_date) as month_start_date
    from {{ ref('fct_encounters') }} as encounters
    inner join dates
        on dates.date_day = encounters.admitted_date

),

monthly as (

    select
        dates.month_start_date                                          as claim_month,
        claims.payer,

        count(*)                                                        as claims,
        sum(claims.submitted_charge_usd)                                as total_submitted_usd,
        sum(claims.allowed_amount_usd)                                  as total_allowed_usd,
        sum(claims.patient_responsibility_usd)                          as total_patient_responsibility_usd,
        sum(claims.payer_paid_usd)                                      as total_payer_paid_usd,
        cast(avg(claims.drg_weight) as decimal(6, 4))                   as case_mix_index,

        sum(cast(claims.is_fraud_upcoding as int))                      as upcoding_claims,
        sum(cast(claims.is_fraud_duplicate as int))                     as duplicate_claims,
        sum(cast(claims.is_fraud_unbundling as int))                    as unbundling_claims,
        sum(cast(claims.has_any_fraud_flag as int))                     as flagged_claims,
        sum(case when claims.has_any_fraud_flag = 1
                 then claims.submitted_charge_usd else 0 end)           as flagged_submitted_usd

    from claims
    inner join dates
        on dates.date_day = claims.claim_date
    group by dates.month_start_date, claims.payer

)

select
    monthly.claim_month,
    cast(case when monthly.claim_month > last_admission_month.month_start_date
              then 1 else 0 end as bit)                                 as is_partial_month,
    monthly.payer,

    -- volume & amounts
    monthly.claims,
    monthly.total_submitted_usd,
    monthly.total_allowed_usd,
    monthly.total_patient_responsibility_usd,
    monthly.total_payer_paid_usd,
    cast(monthly.total_allowed_usd
         / nullif(monthly.total_submitted_usd, 0) as decimal(6, 4))     as allowed_to_submitted_ratio,
    monthly.case_mix_index,

    -- fraud monitoring
    monthly.upcoding_claims,
    cast(monthly.upcoding_claims * 1.0 / monthly.claims as decimal(5, 4))   as upcoding_rate,
    monthly.duplicate_claims,
    cast(monthly.duplicate_claims * 1.0 / monthly.claims as decimal(5, 4))  as duplicate_rate,
    monthly.unbundling_claims,
    cast(monthly.unbundling_claims * 1.0 / monthly.claims as decimal(5, 4)) as unbundling_rate,
    monthly.flagged_claims,
    cast(monthly.flagged_claims * 1.0 / monthly.claims as decimal(5, 4))    as flagged_claim_rate,
    monthly.flagged_submitted_usd

from monthly
cross join last_admission_month
