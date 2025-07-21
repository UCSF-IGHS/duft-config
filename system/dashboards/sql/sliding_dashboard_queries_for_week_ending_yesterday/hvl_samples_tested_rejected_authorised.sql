SELECT
    unpvt.week_name,
    unpvt.category,
    unpvt.value,
    ROW_NUMBER() OVER (
        ORDER BY CASE
            WHEN unpvt.category = 'Sample Received' THEN 1
            WHEN unpvt.category = 'Sample Tested' THEN 2
            WHEN unpvt.category = 'Sample Rejected' THEN 3
            WHEN unpvt.category = 'Sample Results Dispatched' THEN 4
        END
    ) AS sort_order
FROM (
    SELECT
        CASE DATENAME(WEEKDAY, GETDATE())
            WHEN 'Monday' THEN d.weekly_start_monday_period
            WHEN 'Tuesday' THEN d.weekly_start_tuesday_period
            WHEN 'Wednesday' THEN d.weekly_start_wednesday_period
            WHEN 'Thursday' THEN d.weekly_start_thursday_period
            WHEN 'Friday' THEN d.weekly_start_friday_period
            WHEN 'Saturday' THEN d.weekly_start_saturday_period
            WHEN 'Sunday' THEN d.weekly_start_sunday_period
        END AS week_name,
        SUM(s.hvl_sample_received) AS [Sample Received],
		SUM(s.hvl_sample_tested) AS [Sample Tested],
		SUM(s.hvl_sample_rejected) AS [Sample Rejected],
		SUM(s.hvl_result_dispatched) AS [Sample Results Dispatched]
    FROM
        final.fact_daily_sample_summary s
    INNER JOIN derived.dim_date d ON s.report_date = d.date
    WHERE
        s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) AND
        s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
    GROUP BY
        CASE DATENAME(WEEKDAY, GETDATE())
            WHEN 'Monday' THEN d.weekly_start_monday_period
            WHEN 'Tuesday' THEN d.weekly_start_tuesday_period
            WHEN 'Wednesday' THEN d.weekly_start_wednesday_period
            WHEN 'Thursday' THEN d.weekly_start_thursday_period
            WHEN 'Friday' THEN d.weekly_start_friday_period
            WHEN 'Saturday' THEN d.weekly_start_saturday_period
            WHEN 'Sunday' THEN d.weekly_start_sunday_period
        END
) AS Source
UNPIVOT (
    value FOR category IN (
        [Sample Received], 
        [Sample Tested], 
        [Sample Rejected], 
        [Sample Results Dispatched]
    )
) AS unpvt
ORDER BY
    unpvt.week_name,
    sort_order;
