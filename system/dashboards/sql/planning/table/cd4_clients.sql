SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Last VL Test Date],
    [Last VL Result Date],
    [Last VL Result Numeric] AS [Last VL Result],
    [Last CD4 Result Count],
    [Eligible for CD4 Up to Next Week],
    [Became Eligible for CD4 Date],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Current Height (CM)],
    [Current Weight (KG)],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for CD4 Up to Next Week] = 'Yes'