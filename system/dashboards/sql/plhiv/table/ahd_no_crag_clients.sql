SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Is Recently Initiated] AS [TX_NEW],
    [WHO Stage 3/4 Result],
    [WHO Stage 3/4 With No CD4 Test],
    [Traced Back After LTFU],
    NULL AS [Persistent HVL Post EAC],
    [Last CD4 Test Date],
    [Last CD4 Result Count],
    [Last CD4 < 200]
FROM
    duft.fact_duft_sentinel_event
WHERE
(
    [Last CD4 < 200] = 'Yes'
OR
    [WHO Stage 3/4 With No CD4 Test] = 'Yes'
)
AND
    [Last Appointment in Previous Week] = 'Yes'
ORDER BY
    [Patient ID] ASC