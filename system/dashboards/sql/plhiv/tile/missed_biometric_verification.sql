SELECT
    COUNT(DISTINCT([Patient ID]))
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Biometric Verification] = 'Yes'