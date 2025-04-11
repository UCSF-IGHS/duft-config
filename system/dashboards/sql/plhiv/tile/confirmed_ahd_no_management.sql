SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
(
    [Last Appointment in Previous Week] = 'Yes'
    OR
    [CrAg Test Result in Previous Week] = 'Yes'
)
AND 
(
    [CrAg Test Results] = 'Pos'
    AND [Crag Test Within 30 Days] = 'Yes'
    AND (
        [CI Received Cryptococcal Prophylaxis] = 'No'
        OR [CM Received Cryptococcal Treatment] = 'No'
    )
)
