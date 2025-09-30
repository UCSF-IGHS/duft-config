SELECT
	TRIM(df.facility_name) AS category,
	SUM(s.hvl_sample_referred) AS [Total Samples Referred],
	SUM(s.hvl_sample_referred_rejected) AS [Rejected Referred Samples],
	SUM(s.hvl_sample_referred_resulted) AS [Referred Samples with Results]
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
	INNER JOIN derived.fact_sample_testing f ON s.hfr_id_for_HUB_sample_is_coming_from = f.[_hfr_id] 
	INNER JOIN derived.dim_facility df ON f.referral_facility_id = df.hfr_code
WHERE
	s.report_date >= DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 6), GETDATE ())
	AND s.report_date <= DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ())
GROUP BY
	d.weekly_start_monday_period,
	TRIM(df.facility_name)
HAVING
	SUM(s.hvl_sample_referred) <> 0
ORDER BY
	category ASC;