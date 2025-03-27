SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
(
    [Last CD4 < 200] = 'Yes'
OR
    [WHO Stage 3/4 With No CD4 Test] = 'Yes'
)
AND
    [Last Visit in Previous Week] = 'Yes'