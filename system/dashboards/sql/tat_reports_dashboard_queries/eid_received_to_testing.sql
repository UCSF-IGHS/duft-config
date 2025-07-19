SELECT
    tat_category AS category,
    SUM(sample_count) AS value
FROM
(
    SELECT '<=5 days' AS tat_category, SUM(s.eid_sample_received_and_tested_date_in_less_or_equal_5_days) AS sample_count
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '6 to 10 days' AS tat_category, SUM(s.eid_sample_received_and_tested_date_between_6_to_10_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '11 to 15 days' AS tat_category, SUM(s.eid_sample_received_and_tested_date_between_11_to_15_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '>15 days' AS tat_category, SUM(s.eid_sample_received_and_tested_date_greater_than_15_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]
) AS flattened
GROUP BY
    tat_category
ORDER BY
    value DESC;
