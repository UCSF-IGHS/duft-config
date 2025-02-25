SELECT
    dc.ctc_id AS [CTC ID],
    dei.exposed_infant_number AS [Exposed Infant Number],
    gender AS [Sex],
    exposed_infant_date_of_birth AS [DOB],
    dbo.fn_staging_calculate_age(exposed_infant_date_of_birth, GETDATE()) AS [Current Age],
    dbo.fn_calculate_months_between_dates(exposed_infant_date_of_birth, GETDATE()) AS [Age in Months]
    -- feic.exposed_infant_outcome AS [Final Outcome],
    -- feic.exposed_infant_outcome_date AS [Final Outcome Date]
FROM
    derived.dim_exposed_infant dei
INNER JOIN derived.dim_client dc
    ON dei.mother_ctc_number = dc.ctc_id
LEFT JOIN base.fact_exposed_infant_outcome feic
    ON dei.exposed_infant_id = feic.exposed_infant_id
WHERE
    dbo.fn_calculate_months_between_dates(exposed_infant_date_of_birth, GETDATE()) BETWEEN 18 AND 24
    AND feic.exposed_infant_outcome IS NULL
ORDER BY
    dc.client_id
