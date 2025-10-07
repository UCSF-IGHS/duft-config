SELECT
	fs.clean_rejection_reason AS category,
	dd.weekly_start_monday_period AS week_name,
	SUM(fs.is_sample_rejected) AS value
FROM
	[derived].fact_sample_testing fs
INNER JOIN derived.dim_date dd on fs.lab_received_date = dd.[date] 
WHERE
(dd.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
AND dd.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()))
AND fs.is_sample_rejected  = 1
AND fs.is_hvl_sample = 1
GROUP BY
	dd.weekly_start_monday_period,
	fs.clean_rejection_reason
ORDER BY
	value DESC;