SELECT
    tat_category AS category,
    SUM(sample_count) AS value
FROM
(
    SELECT 1 AS sort_order,'<=5 days' AS tat_category, SUM(s.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days) AS sample_count
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 2 AS sort_order,'6 to 10 days' AS tat_category, SUM(s.hvl_sample_received_and_authorised_date_between_6_to_10_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 3 AS sort_order,'11 to 15 days' AS tat_category, SUM(s.hvl_sample_received_and_authorised_date_between_11_to_15_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 4 AS sort_order,'>15 days' AS tat_category, SUM(s.hvl_sample_received_and_authorised_date_greater_than_15_days)
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]
) AS flattened
GROUP BY
    sort_order,
    tat_category
ORDER BY
    sort_order;
