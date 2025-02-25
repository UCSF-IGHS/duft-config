WITH last_antibody_test AS (
    SELECT
        lat.exposed_infant_id,
        lat.mother_ctc_number,
        lat.exposed_infant_number,
        lat.eid_test_date,
        lat.eid_test_type,
        lat.eid_result_date,
        lat.eid_result,
        ROW_NUMBER() OVER (PARTITION BY lat.exposed_infant_number ORDER BY lat.eid_test_date DESC) AS rn
    FROM
         base.fact_eid_test lat
    WHERE
        eid_test_type = 'A'
), last_eid_visit AS (
    SELECT
        lev.exposed_infant_id,
        lev.eid_visit_date,
        ROW_NUMBER() OVER (PARTITION BY lev.exposed_infant_id ORDER BY lev.eid_visit_date DESC) AS rn
    FROM
        base.fact_eid_visits lev
)

SELECT
    dc.ctc_id AS [CTC ID],
    dei.exposed_infant_number AS [Exposed Infant Number],
    gender AS [Sex],
    exposed_infant_date_of_birth AS [DOB],
    dbo.fn_calculate_months_between_dates(exposed_infant_date_of_birth, GETDATE()) AS [Age in Months],
    lev.eid_visit_date AS [Last EID Visit Date],
    lat.eid_test_date AS [Last Antibody Test Date],
    lat.eid_test_type AS [Last Antibody Test Type],
    lat.eid_result_date AS [Last Antibody Result Date],
    lat.eid_result AS [Last Antibody Result],
    tei.ChildPatientID AS [Child's CTC ID],
    CASE
        WHEN tei.ChildPatientID IS NULL OR TRIM(tei.ChildPatientID) = ''
            THEN 'No'
        ELSE 'Yes'
    END AS [Initiated on ART?]
FROM
    derived.dim_exposed_infant dei
INNER JOIN derived.dim_client dc
    ON dei.mother_ctc_number = dc.ctc_id
INNER JOIN ctc_a_source.dbo.tblExposedInfants tei
    ON dei.exposed_infant_number = tei.ExposedInfantID
LEFT JOIN
    last_antibody_test lat
    ON dei.exposed_infant_id = lat.exposed_infant_id
    AND lat.rn = 1
LEFT JOIN
    last_eid_visit lev
    ON dei.exposed_infant_id = lev.exposed_infant_id
    AND lev.rn = 1
WHERE
    lat.eid_result = 'POS'
ORDER BY
    dc.client_id