SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.hvl_samples_aging_is_less_than_or_equal_to_7_days) AS [<=7days],
	SUM(s.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days) AS [8 to 14 days],
	SUM(s.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days) AS [15 to 21 days],
	SUM(s.hvl_samples_aging_is_greater_than_21_days) AS [>21 days and above]
FROM
	final.fact_daily_sample_summary s
INNER JOIN derived.dim_date d ON
	s.report_date = d.date
WHERE
	s.report_date >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND s.report_date <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY
	d.weekly_start_monday_period;