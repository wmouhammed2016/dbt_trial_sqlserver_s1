-- Staging model for raw.encounters
-- One row per encounter (grain: encounter_id).
-- Job of this layer: cast VARCHAR columns to real data types and apply
-- consistent naming (booleans -> is_/has_, timestamps -> _at).
-- No joins, no aggregations, no business logic.
-- The staging layer is the one responsible for mapping the raw data to a clean and properly typed schema.
-- We are going to build the tests and the proper data typing in this layer too.

with

source as (

    select * from {{ source('raw', 'encounters') }}

),

renamed as (

    select
        -- keys
        cast(encounter_id as varchar(36))                       as encounter_id,
        cast(patient_id as varchar(20))                         as patient_id,
        cast(claim_id as varchar(20))                           as claim_id,

        -- patient demographics
        cast(birth_year as smallint)                            as birth_year,
        cast(age as smallint)                                   as age,
        cast(sex as varchar(10))                                as sex,
        cast(race_ethnicity as varchar(20))                     as race_ethnicity,
        cast(state as char(2))                                  as patient_state,

        -- diagnosis & comorbidities
        cast(icd10_code as varchar(10))                         as icd10_code,
        cast(diagnosis_display as varchar(255))                 as diagnosis_display,
        cast(diagnosis_category as varchar(10))                 as diagnosis_category,
        cast(severity_index as decimal(4, 3))                   as severity_index,
        cast(comorbidity_count as smallint)                     as comorbidity_count,
        cast(has_diabetes as bit)                               as has_diabetes,
        cast(has_hypertension as bit)                           as has_hypertension,
        cast(has_chf as bit)                                    as has_chf,

        -- vitals
        cast(sbp_mmhg as decimal(5, 1))                         as sbp_mmhg,
        cast(dbp_mmhg as decimal(5, 1))                         as dbp_mmhg,
        cast(heart_rate_bpm as decimal(5, 1))                   as heart_rate_bpm,
        cast(spo2_pct as decimal(4, 1))                         as spo2_pct,
        cast(temperature_f as decimal(4, 1))                    as temperature_f,
        cast(bmi as decimal(4, 1))                              as bmi,
        cast(respiratory_rate as smallint)                      as respiratory_rate,

        -- labs
        cast(hba1c_pct as decimal(4, 1))                        as hba1c_pct,
        cast(glucose_mg_dl as decimal(5, 1))                    as glucose_mg_dl,
        cast(creatinine_mg_dl as decimal(4, 2))                 as creatinine_mg_dl,
        cast(wbc_10e3_ul as decimal(5, 2))                      as wbc_10e3_ul,
        cast(nt_probnp_pg_ml as decimal(7, 1))                  as nt_probnp_pg_ml,
        cast(medication_adherence_pdc as decimal(3, 2))         as medication_adherence_pdc,
        cast(readmission_30d_flag as bit)                       as is_readmitted_30d,

        -- patient flow & beds
        cast(triage_timestamp as datetime2(0))                  as triaged_at,
        cast(admit_timestamp as datetime2(0))                   as admitted_at,
        cast(bed_request_time as datetime2(0))                  as bed_requested_at,
        cast(bed_assign_time as datetime2(0))                   as bed_assigned_at,
        cast(discharge_timestamp as datetime2(0))               as discharged_at,
        cast(unit_assigned as varchar(20))                      as unit_assigned,
        cast(bed_occupancy_pct as decimal(4, 1))                as bed_occupancy_pct,
        cast(los_days as smallint)                              as los_days,

        -- procedure & operating room
        cast(cpt_code as varchar(5))                            as cpt_code,
        cast(procedure_display as varchar(255))                 as procedure_display,
        cast(or_start as datetime2(0))                          as or_started_at,
        cast(or_end as datetime2(0))                            as or_ended_at,
        cast(actual_or_minutes as smallint)                     as actual_or_minutes,
        cast(or_turnover_minutes as smallint)                   as or_turnover_minutes,

        -- patient safety
        cast(safety_incident_flag as bit)                       as has_safety_incident,
        cast(incident_type as varchar(30))                      as incident_type,
        cast(incident_severity as varchar(15))                  as incident_severity,

        -- claims & billing
        cast(payer as varchar(20))                              as payer,
        cast(npi_billing as varchar(10))                        as npi_billing,
        cast(drg_weight as decimal(6, 4))                       as drg_weight,
        cast(submitted_charge_usd as decimal(12, 2))            as submitted_charge_usd,
        cast(allowed_amount_usd as decimal(12, 2))              as allowed_amount_usd,
        cast(patient_responsibility_usd as decimal(12, 2))      as patient_responsibility_usd,
        cast(fraud_upcoding_flag as bit)                        as is_fraud_upcoding,
        cast(fraud_duplicate_flag as bit)                       as is_fraud_duplicate,
        cast(fraud_unbundling_flag as bit)                      as is_fraud_unbundling,

        -- nurse staffing
        cast(nurse_emp_id as varchar(20))                       as nurse_emp_id,
        cast(nurse_role as varchar(20))                         as nurse_role,
        cast(nurse_unit as varchar(20))                         as nurse_unit,
        cast(nurse_tenure_years as decimal(4, 1))               as nurse_tenure_years,
        cast(nurse_fte as decimal(3, 2))                        as nurse_fte,
        cast(shift_hours as smallint)                           as shift_hours,
        cast(patients_per_nurse_ratio as smallint)              as patients_per_nurse_ratio,
        cast(overtime_hours as decimal(4, 1))                   as overtime_hours,
        cast(burnout_exhaustion_mbi as decimal(3, 2))           as burnout_exhaustion_mbi,
        cast(burnout_cynicism_mbi as decimal(3, 2))             as burnout_cynicism_mbi,
        cast(burnout_personal_accomplishment_mbi as decimal(3, 2)) as burnout_personal_accomplishment_mbi,
        cast(turnover_risk_index as decimal(4, 3))              as turnover_risk_index,

        -- surgeon
        cast(surgeon_emp_id as varchar(20))                     as surgeon_emp_id,
        cast(surgeon_specialty as varchar(30))                  as surgeon_specialty,

        -- CAHPS patient experience (1-5 scale)
        cast(cahps_nurse_communication as decimal(2, 1))        as cahps_nurse_communication,
        cast(cahps_doctor_communication as decimal(2, 1))       as cahps_doctor_communication,
        cast(cahps_responsiveness as decimal(2, 1))             as cahps_responsiveness,
        cast(cahps_pain_management as decimal(2, 1))            as cahps_pain_management,
        cast(cahps_discharge_info as decimal(2, 1))             as cahps_discharge_info,
        cast(cahps_care_transition as decimal(2, 1))            as cahps_care_transition,
        cast(cahps_cleanliness as decimal(2, 1))                as cahps_cleanliness,
        cast(cahps_quietness as decimal(2, 1))                  as cahps_quietness,

        -- surgical kit inventory
        cast(surgical_kit_id as varchar(30))                    as surgical_kit_id,
        cast(kit_name as varchar(30))                           as kit_name,
        cast(kit_unit_cost_usd as decimal(10, 2))               as kit_unit_cost_usd,
        cast(kit_current_stock as smallint)                     as kit_current_stock,
        cast(kit_reorder_point as smallint)                     as kit_reorder_point,
        cast(kit_lead_time_days as smallint)                    as kit_lead_time_days,
        cast(kit_expiration_date as date)                       as kit_expiration_date,
        cast(stockout_risk_flag as bit)                         as is_stockout_risk,
        cast(weekly_procedure_volume as smallint)               as weekly_procedure_volume,
        cast(projected_demand_4wk as smallint)                  as projected_demand_4wk,
        cast(days_of_supply as decimal(5, 1))                   as days_of_supply,

        -- quality measures & digital maturity
        cast(hedis_hba1c_tested as bit)                         as is_hedis_hba1c_tested,
        cast(hedis_hba1c_poor_control as bit)                   as is_hedis_hba1c_poor_control,
        cast(pdsa_cycle_id as varchar(20))                      as pdsa_cycle_id,
        cast(himss_emram_stage as tinyint)                      as himss_emram_stage

    from source

)

select * from renamed
