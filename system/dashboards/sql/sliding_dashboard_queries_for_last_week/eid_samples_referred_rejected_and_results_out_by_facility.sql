SELECT
	TRIM(df.facility_name) AS category,
	SUM(fst.is_referred) AS [Total Samples Referred],
	SUM(fst.is_referred_rejected) AS [Rejected Referred Samples],
	SUM(fst.is_referred_resulted) AS [Referred Samples with Results]
FROM
	derived.fact_sample_testing fst
	INNER JOIN derived.dim_date d ON fst.lab_received_date = d.date
	INNER JOIN derived.dim_facility df ON df.hfr_code  = fst.referral_facility_id 
WHERE
	fst.referred_date >= DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 6), GETDATE ())
	AND fst.referred_date <= DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ())
	AND fst.is_eid_sample = 1
	AND fst.is_valid_record  = 1
	AND fst.is_referred = 1
GROUP BY
	d.weekly_start_monday_period,
	TRIM(df.facility_name)
ORDER BY
	category ASC;