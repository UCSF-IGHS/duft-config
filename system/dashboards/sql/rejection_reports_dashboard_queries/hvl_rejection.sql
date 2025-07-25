SELECT
    d.clean_rejection_reason AS category,
    sum(f.is_rejected_at_the_testing_lab_on_report_date) AS value
FROM
    [derived].fact_daily_hvl_sample_status f
INNER JOIN [derived].dim_sample d on d.sample_id = f.sample_id
WHERE
    f.is_rejected_at_the_testing_lab_on_report_date = 1
    AND f.report_date >= $[start_date%d]
    AND f.report_date <= $[end_date%d]
GROUP BY
    d.clean_rejection_reason
ORDER BY
    value DESC;
