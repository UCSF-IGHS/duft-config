SELECT
    [Patient ID] AS [Mother Patient ID],
    [Due Date],
    [Delivery Date] AS [Date of Delivery]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [HEI Registered] = 'No'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]