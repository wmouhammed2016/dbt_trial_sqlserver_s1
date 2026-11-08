/* =====================================================================
   Step 3 - Validate the load
   Every "expected" value below was calculated directly from
   encounters_100k.csv, so each check should return status = 'PASS'.
   ===================================================================== */

USE healthcare_dbt_dw;
GO

WITH checks AS
(
    SELECT 'row count'                      AS check_name, CAST(COUNT(*) AS varchar(30))                     AS actual, '50000'         AS expected FROM raw.encounters
    UNION ALL
    SELECT 'distinct encounter_id',          CAST(COUNT(DISTINCT encounter_id) AS varchar(30)),                          '50000'                     FROM raw.encounters
    UNION ALL
    SELECT 'distinct claim_id',              CAST(COUNT(DISTINCT claim_id) AS varchar(30)),                              '50000'                     FROM raw.encounters
    UNION ALL
    SELECT 'diagnosis_display with comma',   CAST(SUM(CASE WHEN diagnosis_display LIKE '%,%' THEN 1 ELSE 0 END) AS varchar(30)), '16507'          FROM raw.encounters
    UNION ALL
    SELECT 'procedure_display with comma',   CAST(SUM(CASE WHEN procedure_display LIKE '%,%' THEN 1 ELSE 0 END) AS varchar(30)), '10122'          FROM raw.encounters
    UNION ALL
    SELECT 'values still wrapped in quotes', CAST(SUM(CASE WHEN diagnosis_display LIKE '"%' OR procedure_display LIKE '"%' THEN 1 ELSE 0 END) AS varchar(30)), '0' FROM raw.encounters
    UNION ALL
    SELECT 'blank incident_type (NULL or empty)', CAST(SUM(CASE WHEN NULLIF(incident_type, '') IS NULL THEN 1 ELSE 0 END) AS varchar(30)), '47569' FROM raw.encounters
    UNION ALL
    SELECT 'sum submitted_charge_usd',       CAST(SUM(CAST(submitted_charge_usd AS decimal(18,2))) AS varchar(30)),      '1514284448.09'             FROM raw.encounters
    UNION ALL
    -- catches a stray carriage return (CHAR(13)) left at the end of each line
    SELECT 'last column clean (5/6/7 only)', CAST(SUM(CASE WHEN himss_emram_stage NOT IN ('5','6','7') THEN 1 ELSE 0 END) AS varchar(30)), '0' FROM raw.encounters
)
SELECT check_name,
       actual,
       expected,
       CASE WHEN actual = expected THEN 'PASS' ELSE 'FAIL' END AS status
FROM checks;
GO

-- Eyeball a few rows that contained commas inside quotes
SELECT TOP (5) encounter_id, diagnosis_display, procedure_display, himss_emram_stage
FROM raw.encounters
WHERE procedure_display LIKE '%,%';
GO
