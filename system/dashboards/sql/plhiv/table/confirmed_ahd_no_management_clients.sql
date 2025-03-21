SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Last CD4 Test Date],
    [Last CD4 Result Date],
    [Last CD4 Result Count],
    [Last CD4 < 200],
    [WHO Stage 3/4 Result],
    [WHO Stage 3/4 With No CD4 Test],
    [AHD Suspect]
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