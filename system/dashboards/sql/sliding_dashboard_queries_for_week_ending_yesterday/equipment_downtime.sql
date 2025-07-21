SELECT
	dd.device_name AS Equipment,
	CASE
		WHEN ds.is_broken IS NULL THEN 'Active'
		ELSE 'Inactive'
	END AS Status,
	ds.days_since_broken AS [Days since broken],
	CONVERT(varchar,
	ds.last_date_active,
	23) AS [Last day active],
	ds.breakdown_reason AS [Breakdown Reason]
FROM
	[derived].fact_daily_device_status ds
INNER JOIN [derived].dim_device dd ON
	dd.device_id = ds.device_id
WHERE
	ds.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
    AND ds.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
GROUP BY
	dd.device_name,
	ds.is_broken,
	ds.days_since_broken,
	ds.last_date_active,
	ds.breakdown_reason
ORDER BY
	ds.days_since_broken DESC;