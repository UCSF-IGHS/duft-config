SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for HVL Next Week] = 'Yes'
AND
    [Next Appointment in Next Week] = 'Yes'