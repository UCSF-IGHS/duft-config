SELECT
    COUNT(*)
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Last Antibody Result in Last Week] = 'Yes'
AND
    [Last Antibody Result] = 'POS'
AND
    [Initiated on ART] = 'No'