SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Number of Days Dispensed],
    [Next Appointment Date],
    [Days Since Last Visit],
    [Days Missed Drugs],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Days Missed Appointment],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Current Height (CM)] AS [Height],
    [Current Weight (KG)] AS [Weight],
    [First BP Systolic] AS [BP Reading (Systolic)],
    [First BP Diastolic] AS [BP Reading (Diastolic)],
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
    [Missed Drugs 29-90 Days] = 'Yes'