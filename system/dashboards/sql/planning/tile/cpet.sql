SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for CPeT Next Week] = 'Yes'
AND
    [Next Appointment in Next Week] = 'Yes'