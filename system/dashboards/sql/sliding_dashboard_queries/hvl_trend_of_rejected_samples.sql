SELECT
	d.weekly_start_monday_period AS category,
	CAST(
		COALESCE(
			SUM(s.hvl_sample_rejected) * 100.0 / NULLIF(SUM(s.hvl_sample_received), 0),
			0
		) AS DECIMAL(5, 2)
	) AS value
FROM
	final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON s.report_date = d.date
WHERE
	s.report_date >= DATEADD (
		DAY,
		- (DATEPART (WEEKDAY, GETDATE ()) + 27),
		GETDATE ()
	)
	AND s.report_date <= DATEADD (
		DAY,
		1 - DATEPART (WEEKDAY, GETDATE ()),
		GETDATE ()
	)
GROUP BY
	d.weekly_start_monday_period;