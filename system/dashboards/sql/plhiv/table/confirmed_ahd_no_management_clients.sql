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
    [Last Appointment in Previous Week] = 'Yes'
AND
    [CrAg Test Results] = 'Pos'
AND
    [Crag Test Within 30 Days] = 'Yes'
AND
(
    [CI Received Cryptococcal Prophylaxis] = 'No'
OR
    [CM Received Cryptococcal Treatment] = 'No'
)
ORDER BY
    [Patient ID] ASC