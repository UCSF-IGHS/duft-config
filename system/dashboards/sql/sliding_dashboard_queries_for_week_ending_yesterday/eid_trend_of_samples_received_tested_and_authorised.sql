SELECT
	ca.category,
	SUM(s.eid_sample_dbs_received) AS [Samples Received],
	SUM(s.eid_sample_tested) AS [Samples Tested],
	SUM(s.eid_result_dispatched) AS [Samples Dispatched]
FROM
	final.fact_daily_sample_summary s
INNER JOIN derived.dim_date d ON
	s.report_date = d.date
CROSS APPLY (
        SELECT
            CASE DATENAME(WEEKDAY, GETDATE())
                WHEN 'Monday' THEN d.weekly_start_monday_period
                WHEN 'Tuesday' THEN d.weekly_start_tuesday_period
                WHEN 'Wednesday' THEN d.weekly_start_wednesday_period
                WHEN 'Thursday' THEN d.weekly_start_thursday_period
                WHEN 'Friday' THEN d.weekly_start_friday_period
                WHEN 'Saturday' THEN d.weekly_start_saturday_period
                WHEN 'Sunday' THEN d.weekly_start_sunday_period
            END AS category
    ) ca
WHERE
	d.date >= DATEADD(DAY, -28, CAST(GETDATE() AS DATE))
    AND d.date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
GROUP BY
	ca.category
ORDER BY
	ca.category ASC;