SELECT
	ca.week_name,
	TRIM(f.region) AS category,
	SUM(s.hvl_sample_received) AS value
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
	INNER JOIN derived.dim_facility f ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
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
            END AS week_name
    ) ca
WHERE
	s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
    AND s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
GROUP BY
	ca.week_name,
	TRIM(f.region)
HAVING
	SUM(s.hvl_sample_received) <> 0
ORDER BY
	ca.week_name ASC;