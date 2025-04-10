SELECT
    [Patient ID] AS [Mother Patient ID],
    [Mother's Age],
    [Date Start ART],
    [Last Visit Date],
    [Due Date],
    [Date of Delivery],
    [HEI Current Age in Weeks]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [HEI Registered] = 'No'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]