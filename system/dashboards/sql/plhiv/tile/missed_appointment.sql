SELECT
    COUNT(DISTINCT([Patient ID]))
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment Date] <= GETDATE()
AND
    DATEDIFF(DAY, [Last Visit Date], [Last Appointment Date]) > 10