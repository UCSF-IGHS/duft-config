SELECT
	dt.weekly_start_sunday_period AS week_name,
	dd.device_name AS category,
	COUNT(ds.sample_id) AS value
FROM
	[derived].dim_sample ds
INNER JOIN [derived].dim_device dd ON
	ds.device_id = dd.device_id
INNER JOIN [derived].dim_date dt ON
	ds.tested_date = dt.[date]
WHERE
	dt.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
	AND dt.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
GROUP BY
	dt.weekly_start_sunday_period,
	dd.device_name
ORDER BY
	value DESC;