/* =====================================================================
   Step 1 - Create the RAW landing schema and table
   Database : healthcare_dbt_dw
   Source   : encounters_100k.csv  (255,000 rows x 93 columns)

   Design: every column is VARCHAR on purpose. The raw layer stores the
   file exactly as delivered, so the load never fails on a bad value.
   Data types are applied later in the dbt staging model (stg_encounters).
   ===================================================================== */

USE healthcare_dbt_dw;
GO

IF SCHEMA_ID(N'raw') IS NULL
    EXEC (N'CREATE SCHEMA raw AUTHORIZATION dbo;');
GO

DROP TABLE IF EXISTS raw.encounters;
GO

CREATE TABLE raw.encounters
(
    [patient_id]                          VARCHAR(255) NULL,
    [birth_year]                          VARCHAR(255) NULL,
    [age]                                 VARCHAR(255) NULL,
    [sex]                                 VARCHAR(255) NULL,
    [race_ethnicity]                      VARCHAR(255) NULL,
    [state]                               VARCHAR(255) NULL,
    [encounter_id]                        VARCHAR(255) NULL,
    [icd10_code]                          VARCHAR(255) NULL,
    [diagnosis_display]                   VARCHAR(255) NULL,
    [diagnosis_category]                  VARCHAR(255) NULL,
    [severity_index]                      VARCHAR(255) NULL,
    [comorbidity_count]                   VARCHAR(255) NULL,
    [has_diabetes]                        VARCHAR(255) NULL,
    [has_hypertension]                    VARCHAR(255) NULL,
    [has_chf]                             VARCHAR(255) NULL,
    [sbp_mmhg]                            VARCHAR(255) NULL,
    [dbp_mmhg]                            VARCHAR(255) NULL,
    [heart_rate_bpm]                      VARCHAR(255) NULL,
    [spo2_pct]                            VARCHAR(255) NULL,
    [temperature_f]                       VARCHAR(255) NULL,
    [bmi]                                 VARCHAR(255) NULL,
    [respiratory_rate]                    VARCHAR(255) NULL,
    [hba1c_pct]                           VARCHAR(255) NULL,
    [glucose_mg_dl]                       VARCHAR(255) NULL,
    [creatinine_mg_dl]                    VARCHAR(255) NULL,
    [wbc_10e3_ul]                         VARCHAR(255) NULL,
    [nt_probnp_pg_ml]                     VARCHAR(255) NULL,
    [medication_adherence_pdc]            VARCHAR(255) NULL,
    [readmission_30d_flag]                VARCHAR(255) NULL,
    [triage_timestamp]                    VARCHAR(255) NULL,
    [admit_timestamp]                     VARCHAR(255) NULL,
    [bed_request_time]                    VARCHAR(255) NULL,
    [bed_assign_time]                     VARCHAR(255) NULL,
    [unit_assigned]                       VARCHAR(255) NULL,
    [bed_occupancy_pct]                   VARCHAR(255) NULL,
    [cpt_code]                            VARCHAR(255) NULL,
    [procedure_display]                   VARCHAR(255) NULL,
    [or_start]                            VARCHAR(255) NULL,
    [or_end]                              VARCHAR(255) NULL,
    [actual_or_minutes]                   VARCHAR(255) NULL,
    [or_turnover_minutes]                 VARCHAR(255) NULL,
    [los_days]                            VARCHAR(255) NULL,
    [discharge_timestamp]                 VARCHAR(255) NULL,
    [safety_incident_flag]                VARCHAR(255) NULL,
    [incident_type]                       VARCHAR(255) NULL,
    [incident_severity]                   VARCHAR(255) NULL,
    [claim_id]                            VARCHAR(255) NULL,
    [payer]                               VARCHAR(255) NULL,
    [npi_billing]                         VARCHAR(255) NULL,
    [drg_weight]                          VARCHAR(255) NULL,
    [submitted_charge_usd]                VARCHAR(255) NULL,
    [allowed_amount_usd]                  VARCHAR(255) NULL,
    [patient_responsibility_usd]          VARCHAR(255) NULL,
    [fraud_upcoding_flag]                 VARCHAR(255) NULL,
    [fraud_duplicate_flag]                VARCHAR(255) NULL,
    [fraud_unbundling_flag]               VARCHAR(255) NULL,
    [nurse_emp_id]                        VARCHAR(255) NULL,
    [nurse_role]                          VARCHAR(255) NULL,
    [nurse_unit]                          VARCHAR(255) NULL,
    [nurse_tenure_years]                  VARCHAR(255) NULL,
    [nurse_fte]                           VARCHAR(255) NULL,
    [surgeon_emp_id]                      VARCHAR(255) NULL,
    [surgeon_specialty]                   VARCHAR(255) NULL,
    [shift_hours]                         VARCHAR(255) NULL,
    [patients_per_nurse_ratio]            VARCHAR(255) NULL,
    [overtime_hours]                      VARCHAR(255) NULL,
    [burnout_exhaustion_mbi]              VARCHAR(255) NULL,
    [burnout_cynicism_mbi]                VARCHAR(255) NULL,
    [burnout_personal_accomplishment_mbi] VARCHAR(255) NULL,
    [turnover_risk_index]                 VARCHAR(255) NULL,
    [cahps_nurse_communication]           VARCHAR(255) NULL,
    [cahps_doctor_communication]          VARCHAR(255) NULL,
    [cahps_responsiveness]                VARCHAR(255) NULL,
    [cahps_pain_management]               VARCHAR(255) NULL,
    [cahps_discharge_info]                VARCHAR(255) NULL,
    [cahps_care_transition]               VARCHAR(255) NULL,
    [cahps_cleanliness]                   VARCHAR(255) NULL,
    [cahps_quietness]                     VARCHAR(255) NULL,
    [surgical_kit_id]                     VARCHAR(255) NULL,
    [kit_name]                            VARCHAR(255) NULL,
    [kit_unit_cost_usd]                   VARCHAR(255) NULL,
    [kit_current_stock]                   VARCHAR(255) NULL,
    [kit_reorder_point]                   VARCHAR(255) NULL,
    [kit_lead_time_days]                  VARCHAR(255) NULL,
    [kit_expiration_date]                 VARCHAR(255) NULL,
    [stockout_risk_flag]                  VARCHAR(255) NULL,
    [weekly_procedure_volume]             VARCHAR(255) NULL,
    [projected_demand_4wk]                VARCHAR(255) NULL,
    [days_of_supply]                      VARCHAR(255) NULL,
    [hedis_hba1c_tested]                  VARCHAR(255) NULL,
    [hedis_hba1c_poor_control]            VARCHAR(255) NULL,
    [pdsa_cycle_id]                       VARCHAR(255) NULL,
    [himss_emram_stage]                   VARCHAR(255) NULL
);
GO
