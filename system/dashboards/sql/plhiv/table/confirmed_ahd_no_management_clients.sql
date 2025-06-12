SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [CrAg Test Date],
    [CrAg Test Results],
    [Has Cryptococcal Infection],
    [Has Cryptococcal Meningitis],
    [CI Received Cryptococcal Prophylaxis],
    [CM Received Cryptococcal Treatment],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Days Missed Appointment],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Current Height(CM)] AS [Height],
    [Current Weight(KG)] AS [Weight],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [CrAg Test Results] = 'Pos'
        AND [Crag Test Within 30 Days] = 'Yes'
        AND (
            [CI Received Cryptococcal Prophylaxis] = 'No'
            OR [CM Received Cryptococcal Treatment] = 'No'
        )
    )