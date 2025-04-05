SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Drugs 29-90 Days] = 'Yes'
AND
    [Last Appointment in Previous Week] = 'Yes'