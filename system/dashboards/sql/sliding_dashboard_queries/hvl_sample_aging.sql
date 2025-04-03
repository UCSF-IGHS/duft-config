SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.hvl_samples_aging_less_or_equal_1_week) AS [1 week],
	SUM(s.hvl_samples_aging_less_or_equal_2_week) AS [2 weeks],
	SUM(s.hvl_samples_aging_less_or_equal_3_weeks_and_greater_than_2_weeks) AS [3 weeks],
	SUM(s.hvl_samples_aging_greater_than_3_weeks) AS [>3 weeks and above]
FROM
	final.fact_daily_sample_summary s
INNER JOIN derived.dim_date d ON
	s.report_date = d.date
WHERE
	s.report_date >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND s.report_date <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY
	d.weekly_start_monday_period;