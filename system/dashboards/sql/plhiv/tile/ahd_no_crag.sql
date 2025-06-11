SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [AHD Suspect Within 30 Days] = 'Yes'
    OR
        [Last CD4 < 200] = 'Yes'
    )