SELECT
    hpv_category AS category,
    SUM(sample_count) AS value
FROM
(
    SELECT 1 AS sort_order,'Sample Received' AS hpv_category, SUM(s.hpv_sample_received) AS sample_count
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 2 AS sort_order,'Sample Tested' AS hpv_category, SUM(s.hpv_sample_tested )
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 3 AS sort_order,'Sample Rejected' AS hpv_category, SUM(s.hpv_sample_rejected )
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]

    UNION ALL

    SELECT 4 AS sort_order,'Sample Result Dispatched' AS hpv_category, SUM(s.hpv_result_dispatched )
    FROM final.fact_daily_sample_summary s
    WHERE s.report_date >= $[start_date%d]
      AND s.report_date <= $[end_date%d]
) AS flattened
GROUP BY
    sort_order,
    hpv_category
ORDER BY
    sort_order;
