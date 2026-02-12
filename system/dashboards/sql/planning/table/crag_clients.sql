SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [WHO Stage 3/4 Result],
    [Last CD4 Result Count],
    [Last CD4 Test Date],
    [Became Eligible for CrAg Date],
    [Eligible for CrAg Up to Next Week],
    [Last VL Test Date],
    [Last VL Result Date],
    [Last VL Result Numeric] AS [Last VL Result],
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
    [Eligible for CrAg Up to Next Week] = 'Yes'