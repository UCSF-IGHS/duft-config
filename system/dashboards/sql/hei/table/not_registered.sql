SELECT
    [Patient ID],
    [Exposed Infant Number],
    [Child Patient ID],
    [Sex],
    [DOB],
    [Age in Months],
    [Due Date],
    [Delivery Date],
    [First Visit Date After Delivery],
    [HEI Registered],
    [Infant Status]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [HEI Registered] = 'No'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]