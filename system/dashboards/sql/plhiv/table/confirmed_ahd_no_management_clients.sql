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
    [CM Received Cryptococcal Treatment]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [CrAg Test Date] IS NOT NULL
AND
    [Last Appointment in Previous Week] = 'Yes'
ORDER BY
    [Patient ID] ASC