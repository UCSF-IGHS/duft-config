SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Current Age] < 15
AND
    [Last Visit in Previous Week] = 'Yes'