SELECT
    DISTINCT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Number of Days Dispensed],
    [Last Appointment Date] AS [Missed Appointment Date],
    [Now Pregnant/Breastfeeding] AS [Now Pregnant/ Breastfeeding],
    [Last VL Is Unsuppressed] AS [Last Viral Load High(>1000cps/ml)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last Visit in Previous Week] = 'No'
ORDER BY
    [Last Appointment Date] ASC