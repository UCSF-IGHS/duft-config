SELECT
    COUNT(DISTINCT([Patient ID]))
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment Date] <= GETDATE()
AND
   [Last Visit Date] < [Last Appointment Date]