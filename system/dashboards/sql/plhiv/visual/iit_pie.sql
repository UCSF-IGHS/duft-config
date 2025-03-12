SELECT
    [MMD Status] AS category,
    COUNT(*) AS value,
    CAST(ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*)
        FROM duft.fact_duft_sentinel_event
        WHERE [Missed Drugs 29-90 Days] = 'Yes'), 2) AS DECIMAL(5, 2))
     AS percentage
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Drugs 29-90 Days] = 'Yes'
GROUP BY
    [MMD Status]