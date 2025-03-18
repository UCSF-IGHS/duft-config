SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last VL Is Unsuppressed] = 'Yes'
AND
    [Last Date Initiated EAC] IS NULL