SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.eid_sample_dbs_received) AS [Samples Received],
	SUM(s.eid_sample_tested) AS [Samples Tested],
	SUM(s.eid_result_dispatched) AS [Samples Dispatched]
FROM
	final.fact_daily_sample_summary s
INNER JOIN derived.dim_date d ON
	s.report_date = d.date
WHERE
	d.date >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 27), GETDATE())
	AND d.date <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY
	d.weekly_start_monday_period
ORDER BY
	d.weekly_start_monday_period ASC;