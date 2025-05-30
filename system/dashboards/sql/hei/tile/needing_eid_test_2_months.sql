SELECT
    COUNT(*)
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    (
        (
            [HEI Eligible for DNA PCR at Birth] = 'Yes'
            AND [DNA PCR at Birth Sample Collection Date] IS NULL
        )
        OR
        (
            [HEI Eligible for DNA PCR at 4 to 6 Weeks] = 'Yes'
            AND [DNA PCR at 4 to 6 Weeks Sample Collection Date] IS NULL
        )
    )
    AND ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
    -- AND [HEI Current Age in Weeks] = 6