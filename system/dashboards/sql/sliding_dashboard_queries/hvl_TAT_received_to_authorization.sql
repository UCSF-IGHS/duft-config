SELECT
	d.weekly_start_monday_period AS category,
	SUM(s.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days) AS [<=5 days],
	SUM(s.hvl_sample_received_and_authorised_date_between_6_to_10_days) AS [6 to 10 days],
	SUM(s.hvl_sample_received_and_authorised_date_between_11_to_15_days) AS [11 to 15 days],
	SUM(s.hvl_sample_received_and_authorised_date_greater_than_15_days) AS [>15 days]
FROM
	final.fact_daily_sample_summary s
INNER JOIN derived.dim_date d ON
	s.report_date = d.date
WHERE
	s.report_date >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 27), GETDATE())
	AND s.report_date <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY
	d.weekly_start_monday_period
ORDER BY
	d.weekly_start_monday_period;