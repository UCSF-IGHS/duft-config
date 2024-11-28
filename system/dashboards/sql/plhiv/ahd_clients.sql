SELECT
    [CTC ID],
    [Current Age],
    [DOB],
    [Sex],
    [Last CD4 Result Date],
    [Last CD4 Result Count],
    [Last CD4 < 200],
    [WHO Stage 3/4 Date],
    [WHO Stage 3/4 With No CD4 Test],
    [AHD Suspect]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last CD4 < 200] = 'Yes'
    OR [WHO Stage 3/4 With No CD4 Test] = 'Yes'
ORDER BY
    [CTC ID] ASC