SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 'Yes'
AND
    [Last Appointment in Previous Week] = 'Yes'