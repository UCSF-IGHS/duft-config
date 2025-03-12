SELECT
    [CTC ID],
    [Exposed Infant Number],
    [Child CTC ID],
    [Sex],
    [DOB],
    [Age in Months],
    [Last EID Visit Date],
    [Last Antibody Test Date],
    [Last Antibody Test Type],
    [Last Antibody Result Date],
    [Last Antibody Result],
    [Initiated on ART?]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Last Antibody Result] = 'POS'
ORDER BY
    [CTC ID]