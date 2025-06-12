SELECT
    [Patient ID] AS [Mother Patient ID],
    [Mother's Age],
    [Date Mother Start ART],
    [Last Visit Date],
    [Due Date],
    [Date of Birth],
    [Date of Delivery],
    [HEI Current Age in Weeks]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Date Of Birth in Previous Week] = 'Yes'
AND
    [HEI Registered] = 'No'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')