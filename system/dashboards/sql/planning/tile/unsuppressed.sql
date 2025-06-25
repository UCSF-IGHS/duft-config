SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last VL Is Unsuppressed] = 'Yes'
    AND (
        [Last Date Initiated EAC] IS NULL
        OR [Last Date Initiated EAC] < [Last VL Result Date]
    )