SELECT
    fst.clean_rejection_reason AS category,
    COUNT(*) AS value
FROM
    [derived].fact_sample_testing fst
WHERE
    fst.is_sample_rejected = 1
    AND fst.sample_type = 'HIVVL'
    AND fst.lab_received_date >= $[start_date%d]
    AND fst.lab_received_date <= $[end_date%d]
GROUP BY
    fst.clean_rejection_reason
ORDER BY
    value DESC;
