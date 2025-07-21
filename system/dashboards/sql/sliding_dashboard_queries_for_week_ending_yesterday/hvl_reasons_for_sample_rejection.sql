SELECT
	ds.clean_rejection_reason AS category,
	ca.week_name,
	COUNT(*) AS value
FROM
	[derived].dim_sample ds
LEFT JOIN [derived].dim_date dd ON
	dd.date = ds.lab_received_date
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
	AND ds.test_name = 'HIVVL'
	AND ds.sample_quality_status = 'RejectedLab'
	AND ds.clean_rejection_reason <> ''
GROUP BY
	ca.week_name,
	ds.clean_rejection_reason
ORDER BY
	value DESC;