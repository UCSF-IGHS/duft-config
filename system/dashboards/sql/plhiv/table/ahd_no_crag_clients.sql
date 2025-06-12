SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Is Recently Initiated] AS [TX_NEW],
    [WHO Stage 3/4 (Yes/No)],
    [WHO Stage 3/4 With No CD4 Test],
    [Traced Back After LTFU] AS [Traced Back After LTFU(TX_RTT)],
    [Has High VL Post EAC] AS [Persistent High VL After EAC],
    [Last CD4 Test Date],
    [Last CD4 Result Count] AS [Last CD4 Test Result],
    [Last CD4 < 200] AS [Last CD4<200],
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
    (
        [AHD Suspect Within 30 Days] = 'Yes'
    OR
        [Last CD4 < 200] = 'Yes'
    )