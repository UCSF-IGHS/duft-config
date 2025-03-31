SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.hvl_sample_wholeblood_received) AS wholeblood,
	SUM(s.hvl_sample_plasma_received) AS plasma
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
	d.weekly_start_monday_period;