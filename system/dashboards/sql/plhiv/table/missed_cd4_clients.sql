SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last CD4 Test Date],
    [Last CD4 Result Count] AS [Last CD4 Test Result],
    [Last CD4 < 200] AS [Last CD4<200],
    [Last CD4 Result Date],
    [Last CD4 Result in Previous Week],
    [Last CD4 Result Count],
    [Last CD4 < 200],
    [Eligible for CD4],
    [Became Eligible for CD4 Date],
    [Eligible for CD4 Up to Next Week],
    [WHO Stage 3/4 With No CD4 Test],
    [Number of Days Dispensed],
    [Last Appointment Date] AS [Missed Appointment Date],
    [Now Pregnant/Breastfeeding],
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
    [Eligible for CD4] = 'Yes'