SELECT
	TRIM(df.facility_name) AS category,
	SUM(s.eid_sample_referred) AS [Total Samples Referred],
	SUM(s.eid_sample_referred_rejected) AS [Rejected Referred Samples],
	SUM(s.eid_sample_referred_resulted) AS [Referred Samples with Results]
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
	INNER JOIN derived.fact_sample_testing f ON s.hfr_id_for_HUB_sample_is_coming_from = f.[_hfr_id] 
	INNER JOIN derived.dim_facility df ON f.referral_facility_id = df.hfr_code
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
	s.report_date >= DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 6), GETDATE ())
	AND s.report_date <= DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ())
GROUP BY
	ca.week_name,
	TRIM(df.facility_name)
HAVING
	SUM(s.eid_sample_referred) <> 0
ORDER BY
	category ASC;