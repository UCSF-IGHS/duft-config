SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date],
    [CrAg Test Date],
    [Has CrAg Test],
    [CrAg Test Results],
    [Has Cryptococcal Infection],
    [Has Cryptococcal Meningitis],
    [CI Received Cryptococcal Prophylaxis],
    [CM Received Cryptococcal Treatment],
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
        [CrAg Test Results] = 'Pos'
        AND (
            [CI Received Cryptococcal Prophylaxis] = 'No'
            OR [CM Received Cryptococcal Treatment] = 'No'
        )
    )