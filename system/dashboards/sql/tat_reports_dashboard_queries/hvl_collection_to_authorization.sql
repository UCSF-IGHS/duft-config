SELECT
    tat_category AS category,
    SUM(sample_count) AS value
FROM
(
    SELECT '<=10 days' AS tat_category, SUM(s.hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days) AS sample_count
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '11 to 14 days' AS tat_category, SUM(s.hvl_sample_collected_and_authorised_date_between_11_to_14_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '15 to 21 days' AS tat_category, SUM(s.hvl_sample_collected_and_authorised_date_between_15_to_21_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT '>21 days' AS tat_category, SUM(s.hvl_sample_collected_and_authorised_date_greater_than_21_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]
) AS flattened
GROUP BY
    tat_category
ORDER BY
    value DESC;
