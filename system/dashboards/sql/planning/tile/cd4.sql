SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for CD4 Next Week] = 'Yes'
AND
    [Next Appointment in Next Week] = 'Yes'