SELECT
	fs.clean_rejection_reason AS category,
	ca.week_name,
	SUM(fs.is_sample_rejected) AS value
FROM
	[derived].fact_sample_testing fs
INNER JOIN derived.dim_date dd on fs.lab_received_date = dd.[date] 
CROSS APPLY (
        SELECT
            CASE DATENAME(WEEKDAY, GETDATE())
                WHEN 'Monday' THEN dd.weekly_start_monday_period
                WHEN 'Tuesday' THEN dd.weekly_start_tuesday_period
                WHEN 'Wednesday' THEN dd.weekly_start_wednesday_period
                WHEN 'Thursday' THEN dd.weekly_start_thursday_period
                WHEN 'Friday' THEN dd.weekly_start_friday_period
                WHEN 'Saturday' THEN dd.weekly_start_saturday_period
                WHEN 'Sunday' THEN dd.weekly_start_sunday_period
            END AS week_name
    ) ca
WHERE
	dd.[date] >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
    AND dd.[date] <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
    AND fs.is_sample_rejected  = 1
    AND fs.is_hvl_sample = 1
GROUP BY
	ca.week_name,
	fs.clean_rejection_reason
ORDER BY
	value DESC;