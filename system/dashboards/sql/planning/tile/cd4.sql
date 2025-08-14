SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible for CD4 Up to Next Week] = 'Yes'