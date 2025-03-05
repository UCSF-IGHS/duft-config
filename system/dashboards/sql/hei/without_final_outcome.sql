SELECT
    [CTC ID],
    [Exposed Infant Number],
    [Child CTC ID],
    [Sex],
    [DOB],
    [Age in Months],
    [Has Final Outcome?]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Has Final Outcome?] = 'No'
AND
    [Age in Months] BETWEEN 18 AND 24
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [CTC ID]