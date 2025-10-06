SELECT
    clean_rejection_reason AS category,
    sum(is_sample_rejected) AS value
FROM
    [derived].fact_sample_testing
WHERE
    is_sample_rejected = 1
    and is_hvl_sample = 1
    AND lab_received_date >= $[start_date%d]
    AND lab_received_date <= $[end_date%d]
GROUP BY
    clean_rejection_reason
ORDER BY
    value DESC;
