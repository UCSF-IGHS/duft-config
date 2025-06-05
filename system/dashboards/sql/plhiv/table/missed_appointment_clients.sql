SELECT
    DISTINCT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Number of Days Dispensed],
    [Next Appointment Date] AS [Missed Appointment Date],
    [Now Pregnant/Breastfeeding] AS [Now Pregnant/ Breastfeeding],
    [Last VL Is Unsuppressed] AS [Last Viral Load High(>1000cps/ml)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment Date] <= GETDATE()
   AND [Last Visit Date] < [Last Appointment Date]