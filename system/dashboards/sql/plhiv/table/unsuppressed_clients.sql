SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date] AS [Visit Date],
    [Last Prescription Regimen Line] AS [ARV Regimen Line],
    [Months on ART],
    [Now Pregnant/Breastfeeding],
    [Last VL Test Date] AS [Test Date Before Start EAC],
    [Last VL Result Date] AS [Result Date Before Start EAC],
    [Last VL Result Date] AS [Result Return Date],
    [Last Date Initiated EAC] AS [Previous Date Initiated EAC]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last VL Is Unsuppressed] = 'Yes'
AND
    [Last Date Initiated EAC] IS NULL
ORDER BY
    [Patient ID] ASC