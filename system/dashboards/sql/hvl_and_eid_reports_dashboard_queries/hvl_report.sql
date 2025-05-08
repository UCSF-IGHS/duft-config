WITH filtered_data AS (
    SELECT *
    FROM [final].fact_daily_sample_summary fdss
    INNER JOIN [derived].dim_date d ON fdss.report_date = d.date
    WHERE [date] >= '2025-03-16' AND [date] <= '2025-03-23'
),
hvl_pending_results AS (
    SELECT
        day_number,
        [Results pending Authorization]
    FROM (
        SELECT
            fdss.report_date,
            SUM(fdss.hvl_result_pending) AS [Results pending Authorization],
            RANK() OVER (ORDER BY fdss.report_date) AS day_number
        FROM filtered_data fdss
        GROUP BY fdss.report_date
    ) AS subquery
    WHERE day_number = DATEDIFF(day, '2025-03-16', '2025-03-23') + 1
),
hvl_backlog_before_reporting AS (
    SELECT
        SUM(hvl_sample_collected) - SUM(hvl_sample_tested) AS [Backlog at beginning of reporting period]
    FROM [final].fact_daily_sample_summary
    WHERE report_date < '2025-03-16'
),
hvl_backlog_after_reporting AS (
    SELECT
        SUM(hvl_sample_collected) - SUM(hvl_sample_tested) AS [Backlog at end of reporting period]
    FROM [final].fact_daily_sample_summary
    WHERE report_date <= '2025-03-23'
),
hvl_report_table AS (
    SELECT
        SUM(hvl_sample_received) AS [Sample Received],
        SUM(hvl_sample_rejected) AS [Sample Rejected],
        SUM(hvl_sample_tested) AS [Sample Tested],
        SUM(hvl_sample_tested_negative) AS [Tested Negative],
        SUM(hvl_sample_tested_positive) AS [Tested Positive],
        SUM(result_indeterminate) AS Indeterminate,
        SUM(hvl_result_authorized) AS [Results Authorized]
    FROM filtered_data
)
SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [S/N],
    Indicator,
    Total_Count
FROM (
    SELECT
        bb.[Backlog at beginning of reporting period],
        mt.[Sample Received],
        mt.[Sample Rejected],
        mt.[Sample Tested],
        mt.[Tested Negative],
        mt.[Tested Positive],
        mt.[Indeterminate],
        be.[Backlog at end of reporting period],
        mt.[Results Authorized],
        pr.[Results pending Authorization]
    FROM hvl_pending_results pr
    CROSS JOIN hvl_report_table mt
    CROSS JOIN hvl_backlog_before_reporting bb
    CROSS JOIN hvl_backlog_after_reporting be
) AS SourceData
UNPIVOT (
    Total_Count FOR Indicator IN (
        [Backlog at beginning of reporting period],
        [Sample Received],
        [Sample Rejected],
        [Sample Tested],
        [Tested Negative],
        [Tested Positive],
        [Indeterminate],
        [Backlog at end of reporting period],
        [Results Authorized],
        [Results pending Authorization]
    )
) AS UnpivotedData;
