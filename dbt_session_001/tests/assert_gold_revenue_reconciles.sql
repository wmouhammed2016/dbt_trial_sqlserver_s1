-- Revenue totals in the gold mart must equal fct_claims to the cent.
-- Returns one row per measure that does not match.

with silver as (

    select
        count(*)                            as claims,
        sum(submitted_charge_usd)           as submitted,
        sum(allowed_amount_usd)             as allowed,
        sum(patient_responsibility_usd)     as patient_responsibility,
        sum(cast(has_any_fraud_flag as int)) as flagged_claims
    from {{ ref('fct_claims') }}

),

gold as (

    select
        sum(claims)                             as claims,
        sum(total_submitted_usd)                as submitted,
        sum(total_allowed_usd)                  as allowed,
        sum(total_patient_responsibility_usd)   as patient_responsibility,
        sum(flagged_claims)                     as flagged_claims
    from {{ ref('mart_revenue_cycle_monthly') }}

),

compared as (

    select 'claims' as measure, cast(gold.claims as decimal(18, 2)) as gold_value, cast(silver.claims as decimal(18, 2)) as silver_value from gold cross join silver
    union all
    select 'submitted', gold.submitted, silver.submitted from gold cross join silver
    union all
    select 'allowed', gold.allowed, silver.allowed from gold cross join silver
    union all
    select 'patient_responsibility', gold.patient_responsibility, silver.patient_responsibility from gold cross join silver
    union all
    select 'flagged_claims', gold.flagged_claims, silver.flagged_claims from gold cross join silver

)

select *
from compared
where gold_value <> silver_value
