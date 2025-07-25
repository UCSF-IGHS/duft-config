SELECT
	ds.clean_rejection_reason AS category,
	dd.weekly_start_monday_period AS week_name,
	sum(fs.is_rejected_at_the_testing_lab_on_report_date) AS value
FROM
	[derived].fact_daily_hvl_sample_status fs
INNER JOIN derived.dim_sample ds on ds.sample_id = fs.sample_id
INNER JOIN derived.dim_date dd on ds.lab_received_date = dd.[date] 
WHERE
(dd.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND dd.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()))
AND fs.is_rejected_at_the_testing_lab_on_report_date = 1
GROUP BY
	dd.weekly_start_monday_period,
	ds.clean_rejection_reason
ORDER BY
	value DESC;