SELECT
    COUNT(DISTINCT([Patient ID]))
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment Date] <= GETDATE()
AND
    (
        [Is Marked Transferred Out] = 'No'
        OR [Is Marked Transferred Out] IS NULL
    )
AND
    DATEDIFF(DAY, [Last Visit Date], [Last Appointment Date]) > 10