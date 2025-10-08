SELECT
    fst.rejection_reason AS category,
    COUNT(*) AS value
FROM
    derived.fact_sample_testing fst 
LEFT JOIN 
    derived.dim_date dd 
    ON dd.date = fst.lab_received_date
WHERE
    dd.date >= $[start_date%d]
    AND dd.date <= $[end_date%d]
    AND fst.is_sample_rejected = 1
		AND is_hpv_sample  = 1
        AND is_valid_record = 1
GROUP BY
    fst.rejection_reason
ORDER BY
    value DESC;
