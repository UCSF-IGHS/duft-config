SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.eid_samples_aging_less_than_or_equal_to_7_days_aging) AS [<=7days],
	SUM(s.eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging) AS [8 to 14 days],
	SUM(s.eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging) AS [15 to 21 days],
	SUM(s.eid_samples_greater_than_21_days_aging) AS [>21 days and above]
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
WHERE 
	s.report_date >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND s.report_date <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY 
	d.weekly_start_monday_period;