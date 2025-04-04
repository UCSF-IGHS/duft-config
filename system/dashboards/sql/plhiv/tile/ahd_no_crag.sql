SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment in Previous Week] = 'Yes'
AND
    [AHD Suspect Within 30 Days] = 'Yes'