SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date],
    [Documented Nutritional Status],
    [Calculated Nutritional Status],
    [Documented and Calculated Nutritional Status Match],
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
    [Current Age] < 5
    AND
        (
            [Current Weight (KG)] IS NULL
            OR [Current Height (CM)] IS NULL
            OR [Documented Nutritional Status] IS NULL
            OR [Documented and Calculated Nutritional Status Match] = 'No'
        )