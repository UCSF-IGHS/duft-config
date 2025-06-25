SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [AHD Suspect] = 'Yes'
    OR
        [Last CD4 < 200] = 'Yes'
    )