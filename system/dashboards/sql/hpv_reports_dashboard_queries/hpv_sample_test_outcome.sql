SELECT
    category,
    SUM(value) AS value
FROM
(
    SELECT
        SUM(s.hpv_sample_tested_positive) AS Positive,
        SUM(s.hpv_sample_tested_negative) AS Negative,
        SUM(s.hpv_result_failed) AS Failed,
        SUM(s.hpv_result_invalid) AS Invalid
        
    FROM
        final.fact_daily_sample_summary s
        INNER JOIN derived.dim_date d ON s.report_date = d.date
    WHERE
        s.report_date >= $[start_date%d]
        AND s.report_date <= $[end_date%d]
) AS SampleData
UNPIVOT (
    value FOR category IN (Positive, Negative, Failed, Invalid)
) AS unpvt
GROUP BY
    category
ORDER BY
    CASE category
        WHEN 'Negative' THEN 1
        WHEN 'Invalid'THEN 2
        WHEN 'Failed' THEN 3
        WHEN 'Positive' THEN 4
        ELSE 5
    END;
