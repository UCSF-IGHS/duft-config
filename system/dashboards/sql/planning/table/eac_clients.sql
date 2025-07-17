SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date],
    [Last VL Test Date],
    [Last VL Result Numeric] AS [Last VL Result],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Became Eligible for EAC Date],
    [Eligible for EAC Next Week],
    [Current Height (CM)],
    [Current Weight (KG)],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for EAC Next Week] = 'Yes'
AND
    [Next Appointment in Next Week] = 'Yes'