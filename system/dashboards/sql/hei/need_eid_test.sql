WITH first_eid_test AS (
    SELECT
        fet.exposed_infant_id,
        fet.mother_ctc_number,
        fet.exposed_infant_number,
        fet.eid_test_date,
        fet.eid_test_type,
        fet.eid_result_date,
        fet.eid_result,
        ROW_NUMBER() OVER (PARTITION BY fet.exposed_infant_number ORDER BY fet.eid_test_date ASC) AS rn
    FROM
         base.fact_eid_test fet
    WHERE
        eid_test_type = 'D'
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
    dei.mother_ctc_number AS [Mother CTC Number],
    dei.exposed_infant_number AS [Exposed Infant Number],
    gender AS [Sex],
    exposed_infant_date_of_birth AS [DOB],
    dbo.fn_staging_calculate_age(exposed_infant_date_of_birth, GETDATE()) AS [Current Age],
    lev.eid_visit_date AS [Last EID Visit Date],
    CASE
        WHEN eid_test_date IS NULL
            THEN 'Yes'
        ELSE 'No'
    END AS [Eligible for EID?],
    fet.eid_test_date AS [First EID Test Date],
    fet.eid_test_type AS [First EID Test Type],
    fet.eid_result_date AS [First EID Result Date],
    fet.eid_result AS [First EID Result]
FROM
    derived.dim_exposed_infant dei
INNER JOIN derived.dim_client dc
    ON dei.mother_ctc_number = dc.ctc_id
LEFT JOIN
    first_eid_test fet
    ON dei.exposed_infant_id = fet.exposed_infant_id
    AND fet.rn = 1
LEFT JOIN
    last_eid_visit lev
    ON dei.exposed_infant_id = lev.exposed_infant_id
    AND lev.rn = 1
ORDER BY
    dc.client_id