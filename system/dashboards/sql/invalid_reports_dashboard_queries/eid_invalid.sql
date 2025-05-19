SELECT
    "Report date",
    "Total"
FROM (
    SELECT
        CAST(report_date AS VARCHAR(20)) AS "Report date",
        SUM(fd.eid_result_invalid) AS "Total",
        0 AS sort_order
    FROM
        final.fact_daily_sample_summary fd
    WHERE
        report_date >= $[start_date%d]
        AND report_date <= $[end_date%d]
    GROUP BY
        report_date

    UNION ALL

    SELECT
        'GRAND TOTAL' AS "Report date",
        SUM(fd.eid_result_invalid) AS "Total",
        1 AS sort_order
    FROM
        final.fact_daily_sample_summary fd
    WHERE
        report_date >= $[start_date%d]
        AND report_date <= $[end_date%d]
) AS combined
ORDER BY
    sort_order,
    "Report date";