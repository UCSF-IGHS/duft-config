SELECT
	ca.week_name,
	dd.device_name AS category,
	COUNT(ds.sample_id) AS value
FROM
	[derived].dim_sample ds
INNER JOIN [derived].dim_device dd ON
	ds.device_id = dd.device_id
INNER JOIN [derived].dim_date dt ON
	ds.tested_date = dt.[date]
CROSS APPLY (
        SELECT
            CASE DATENAME(WEEKDAY, GETDATE())
                WHEN 'Monday' THEN dt.weekly_start_monday_period
                WHEN 'Tuesday' THEN dt.weekly_start_tuesday_period
                WHEN 'Wednesday' THEN dt.weekly_start_wednesday_period
                WHEN 'Thursday' THEN dt.weekly_start_thursday_period
                WHEN 'Friday' THEN dt.weekly_start_friday_period
                WHEN 'Saturday' THEN dt.weekly_start_saturday_period
                WHEN 'Sunday' THEN dt.weekly_start_sunday_period
            END AS week_name
    ) ca
WHERE
	dt.[date] >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
    AND dt.[date] <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
GROUP BY
	ca.week_name,
	dd.device_name
ORDER BY
	value DESC;