SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Months],
    [Sex],
    [Last Visit Date],
    [Date of Final Outcome],
    [Documented Final Outcome],
    [HEI Age in Months at Final Outcome]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Last Antibody Result] = 'POS'
ORDER BY
    [Patient ID]