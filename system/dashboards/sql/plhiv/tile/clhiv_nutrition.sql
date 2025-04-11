SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Current Age] < 5
AND
    [Last Visit in Previous Week] = 'Yes'
AND
(
    [Current Weight(KG)] IS NULL
OR
    [Current Weight(KG)] IS NULL
OR
    [Documented Nutritional Status] IS NULL
OR
    [Documented and Calculated Nutritional Status Match] = 'No'
)