SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date],
    [Last Prescription Regimen Line] AS [ARV Regimen],
    [Now Pregnant/Breastfeeding] AS [Now Pregnant/ Breastfeeding],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [Last VL Result Date] AS [VL Result Return Date],
    [Last Date Initiated EAC] AS [Previous Date Initiated EAC],
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
    [Last VL Is Unsuppressed] = 'Yes'
    AND (
        [Last Date Initiated EAC] IS NULL
        OR [Last Date Initiated EAC] < [Last VL Result Date]
    )