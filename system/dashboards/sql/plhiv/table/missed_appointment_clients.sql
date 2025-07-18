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
    [Last VL Is Unsuppressed] AS [Last Viral Load High(>1000cps/ml)],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Days Missed Appointment],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Current Height (CM)],
    [Current Weight (KG)],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment Date] <= GETDATE()
AND
    DATEDIFF(DAY, [Last Visit Date], [Last Appointment Date]) > 10