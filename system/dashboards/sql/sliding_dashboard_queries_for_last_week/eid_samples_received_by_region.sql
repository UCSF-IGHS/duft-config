SELECT
	d.weekly_start_monday_period AS week_name,
	TRIM(f.region) AS category,
	SUM(s.eid_sample_dbs_received) AS value
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
	INNER JOIN derived.dim_facility f ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
WHERE
	s.report_date >= DATEADD (
		DAY,
		- (DATEPART (WEEKDAY, GETDATE ()) + 6),
		GETDATE ()
	)
	AND s.report_date <= DATEADD (
		DAY,
		1 - DATEPART (WEEKDAY, GETDATE ()),
		GETDATE ()
	)
GROUP BY
	d.weekly_start_monday_period,
	TRIM(f.region)
HAVING
	SUM(s.eid_sample_dbs_received) <> 0
ORDER BY
	category ASC;