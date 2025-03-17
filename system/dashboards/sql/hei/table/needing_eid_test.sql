SELECT
    [Patient ID],
    [Exposed Infant Number],
    [Child Patient ID],
    [Sex],
    [DOB],
    [Age in Months],
    [Last EID Visit Date],
    [Eligible for First EID Test]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Eligible for First EID Test] = 'Yes'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]