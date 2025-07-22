SELECT
	ca.category,
	SUM(s.hvl_samples_aging_is_less_than_or_equal_to_7_days) AS [<=7days],
	SUM(s.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days) AS [8 to 14 days],
	SUM(s.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days) AS [15 to 21 days],
	SUM(s.hvl_samples_aging_is_greater_than_21_days) AS [>21 days and above]
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
	s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
    AND s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
GROUP BY
	ca.category;