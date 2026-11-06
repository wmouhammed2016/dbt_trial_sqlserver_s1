/* =====================================================================
   Step 1 - Create the RAW landing schema and table
   Database : healthcare_dbt_dw
   Source   : encounters_100k.csv  (50,000 rows x 93 columns)

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
    [patient_id]                          VARCHAR(50) NULL,
    [birth_year]                          VARCHAR(30) NULL,
    [age]                                 VARCHAR(30) NULL,
    [sex]                                 VARCHAR(50) NULL,
    [race_ethnicity]                      VARCHAR(50) NULL,
    [state]                               VARCHAR(50) NULL,
    [encounter_id]                        VARCHAR(255) NULL,
    [icd10_code]                          VARCHAR(50) NULL,
    [diagnosis_display]                   VARCHAR(255) NULL,
    [diagnosis_category]                  VARCHAR(50) NULL,
    [severity_index]                      VARCHAR(30) NULL,
    [comorbidity_count]                   VARCHAR(30) NULL,
    [has_diabetes]                        VARCHAR(30) NULL,
    [has_hypertension]                    VARCHAR(30) NULL,
    [has_chf]                             VARCHAR(30) NULL,
    [sbp_mmhg]                            VARCHAR(30) NULL,
    [dbp_mmhg]                            VARCHAR(30) NULL,
    [heart_rate_bpm]                      VARCHAR(30) NULL,
    [spo2_pct]                            VARCHAR(30) NULL,
    [temperature_f]                       VARCHAR(30) NULL,
    [bmi]                                 VARCHAR(30) NULL,
    [respiratory_rate]                    VARCHAR(30) NULL,
    [hba1c_pct]                           VARCHAR(30) NULL,
    [glucose_mg_dl]                       VARCHAR(30) NULL,
    [creatinine_mg_dl]                    VARCHAR(30) NULL,
    [wbc_10e3_ul]                         VARCHAR(30) NULL,
    [nt_probnp_pg_ml]                     VARCHAR(30) NULL,
    [medication_adherence_pdc]            VARCHAR(30) NULL,
    [readmission_30d_flag]                VARCHAR(30) NULL,
    [triage_timestamp]                    VARCHAR(30) NULL,
    [admit_timestamp]                     VARCHAR(30) NULL,
    [bed_request_time]                    VARCHAR(30) NULL,
    [bed_assign_time]                     VARCHAR(30) NULL,
    [unit_assigned]                       VARCHAR(50) NULL,
    [bed_occupancy_pct]                   VARCHAR(30) NULL,
    [cpt_code]                            VARCHAR(30) NULL,
    [procedure_display]                   VARCHAR(255) NULL,
    [or_start]                            VARCHAR(30) NULL,
    [or_end]                              VARCHAR(30) NULL,
    [actual_or_minutes]                   VARCHAR(30) NULL,
    [or_turnover_minutes]                 VARCHAR(30) NULL,
    [los_days]                            VARCHAR(30) NULL,
    [discharge_timestamp]                 VARCHAR(30) NULL,
    [safety_incident_flag]                VARCHAR(30) NULL,
    [incident_type]                       VARCHAR(50) NULL,
    [incident_severity]                   VARCHAR(50) NULL,
    [claim_id]                            VARCHAR(50) NULL,
    [payer]                               VARCHAR(50) NULL,
    [npi_billing]                         VARCHAR(30) NULL,
    [drg_weight]                          VARCHAR(30) NULL,
    [submitted_charge_usd]                VARCHAR(30) NULL,
    [allowed_amount_usd]                  VARCHAR(30) NULL,
    [patient_responsibility_usd]          VARCHAR(30) NULL,
    [fraud_upcoding_flag]                 VARCHAR(30) NULL,
    [fraud_duplicate_flag]                VARCHAR(30) NULL,
    [fraud_unbundling_flag]               VARCHAR(30) NULL,
    [nurse_emp_id]                        VARCHAR(50) NULL,
    [nurse_role]                          VARCHAR(50) NULL,
    [nurse_unit]                          VARCHAR(50) NULL,
    [nurse_tenure_years]                  VARCHAR(30) NULL,
    [nurse_fte]                           VARCHAR(30) NULL,
    [surgeon_emp_id]                      VARCHAR(50) NULL,
    [surgeon_specialty]                   VARCHAR(50) NULL,
    [shift_hours]                         VARCHAR(30) NULL,
    [patients_per_nurse_ratio]            VARCHAR(30) NULL,
    [overtime_hours]                      VARCHAR(30) NULL,
    [burnout_exhaustion_mbi]              VARCHAR(30) NULL,
    [burnout_cynicism_mbi]                VARCHAR(30) NULL,
    [burnout_personal_accomplishment_mbi] VARCHAR(30) NULL,
    [turnover_risk_index]                 VARCHAR(30) NULL,
    [cahps_nurse_communication]           VARCHAR(30) NULL,
    [cahps_doctor_communication]          VARCHAR(30) NULL,
    [cahps_responsiveness]                VARCHAR(30) NULL,
    [cahps_pain_management]               VARCHAR(30) NULL,
    [cahps_discharge_info]                VARCHAR(30) NULL,
    [cahps_care_transition]               VARCHAR(30) NULL,
    [cahps_cleanliness]                   VARCHAR(30) NULL,
    [cahps_quietness]                     VARCHAR(30) NULL,
    [surgical_kit_id]                     VARCHAR(50) NULL,
    [kit_name]                            VARCHAR(50) NULL,
    [kit_unit_cost_usd]                   VARCHAR(30) NULL,
    [kit_current_stock]                   VARCHAR(30) NULL,
    [kit_reorder_point]                   VARCHAR(30) NULL,
    [kit_lead_time_days]                  VARCHAR(30) NULL,
    [kit_expiration_date]                 VARCHAR(30) NULL,
    [stockout_risk_flag]                  VARCHAR(30) NULL,
    [weekly_procedure_volume]             VARCHAR(30) NULL,
    [projected_demand_4wk]                VARCHAR(30) NULL,
    [days_of_supply]                      VARCHAR(30) NULL,
    [hedis_hba1c_tested]                  VARCHAR(30) NULL,
    [hedis_hba1c_poor_control]            VARCHAR(30) NULL,
    [pdsa_cycle_id]                       VARCHAR(50) NULL,
    [himss_emram_stage]                   VARCHAR(30) NULL
);
GO
