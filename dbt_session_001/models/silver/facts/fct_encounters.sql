-- One row per hospital encounter.
-- Clinical state, patient flow, OR, safety, patient experience and quality
-- measures, with foreign keys to every dimension.

with encounters as (

    select * from {{ ref('stg_encounters') }}

)

select
    -- keys
    encounter_id,
    patient_id,
    nurse_emp_id,
    surgeon_emp_id,
    icd10_code,
    cpt_code,
    cast(admitted_at as date)                                           as admitted_date,
    cast(discharged_at as date)                                         as discharged_date,

    -- patient flow timeline
    triaged_at,
    admitted_at,
    bed_requested_at,
    bed_assigned_at,
    discharged_at,
    unit_assigned,
    bed_occupancy_pct,

    -- derived flow metrics
    datediff(minute, triaged_at, admitted_at)                           as door_to_admit_minutes,
    datediff(minute, admitted_at, bed_requested_at)                     as admit_to_bed_request_minutes,
    datediff(minute, bed_requested_at, bed_assigned_at)                 as bed_boarding_minutes,
    cast(datediff(minute, admitted_at, discharged_at) / 60.0
         as decimal(7, 2))                                              as los_hours,
    los_days,

    -- operating room
    or_started_at,
    or_ended_at,
    actual_or_minutes,
    or_turnover_minutes,
    cast(case when or_ended_at > discharged_at then 1 else 0 end as bit) as has_timeline_conflict,

    -- clinical state at the encounter
    severity_index,
    comorbidity_count,
    has_diabetes,
    has_hypertension,
    has_chf,
    sbp_mmhg,
    dbp_mmhg,
    heart_rate_bpm,
    spo2_pct,
    temperature_f,
    bmi,
    respiratory_rate,
    hba1c_pct,
    glucose_mg_dl,
    creatinine_mg_dl,
    wbc_10e3_ul,
    nt_probnp_pg_ml,
    medication_adherence_pdc,

    -- outcomes & safety
    is_readmitted_30d,
    has_safety_incident,
    incident_type,
    incident_severity,

    -- nurse shift context (varies per encounter, so not in dim_nurse)
    shift_hours,
    patients_per_nurse_ratio,
    overtime_hours,
    turnover_risk_index,

    -- patient experience (CAHPS, 1-5 scale)
    cahps_nurse_communication,
    cahps_doctor_communication,
    cahps_responsiveness,
    cahps_pain_management,
    cahps_discharge_info,
    cahps_care_transition,
    cahps_cleanliness,
    cahps_quietness,
    cast((cahps_nurse_communication + cahps_doctor_communication + cahps_responsiveness
          + cahps_pain_management + cahps_discharge_info + cahps_care_transition
          + cahps_cleanliness + cahps_quietness) / 8.0
         as decimal(3, 2))                                              as cahps_composite_score,

    -- quality measures & digital maturity
    is_hedis_hba1c_tested,
    is_hedis_hba1c_poor_control,
    pdsa_cycle_id,
    himss_emram_stage

from encounters
