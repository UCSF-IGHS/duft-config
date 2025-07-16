SELECT
    COUNT(*)
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [HEI Current Age in Months] BETWEEN 9 AND 18
AND
    [DNA PCR at 9 Months Sample Collection Date] IS NULL
AND
    [Antibody Test Date at 3 Months Post-BF] IS NULL
AND
    [Antibody Test Date at 18 Months] IS NULL
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')