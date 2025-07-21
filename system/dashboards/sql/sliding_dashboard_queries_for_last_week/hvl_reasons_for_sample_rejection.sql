SELECT
	ds.clean_rejection_reason AS category,
	dd.weekly_start_monday_period AS week_name,
	COUNT(*) AS value
FROM
	[derived].dim_sample ds
LEFT JOIN [derived].dim_date dd ON
	dd.date = ds.lab_received_date
WHERE
	dd.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND dd.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
	AND ds.test_name = 'HIVVL'
	AND ds.sample_quality_status = 'RejectedLab'
	AND ds.clean_rejection_reason <> ''
GROUP BY
	dd.weekly_start_monday_period,
	ds.clean_rejection_reason
ORDER BY
	value DESC;