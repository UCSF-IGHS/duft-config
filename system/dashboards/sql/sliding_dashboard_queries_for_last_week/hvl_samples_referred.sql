SELECT
	week_name,
	category,
	value,
	ROW_NUMBER() OVER (
	ORDER BY CASE
		category WHEN 'Received Samples' THEN 1
		WHEN 'Tested Samples' THEN 2
		WHEN 'Referred Samples' THEN 3
	END) AS sort_order
FROM
	(
	SELECT
		d.weekly_start_monday_period AS week_name,
		SUM(s.eid_sample_dbs_received) AS [Received Samples],
		SUM(s.eid_sample_tested) AS [Tested Samples],
	    SUM(s.eid_sample_referred) AS [Referred Samples]
	FROM
		final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON
		s.report_date = d.date
	WHERE
		d.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
		AND d.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
	GROUP BY
		d.weekly_start_monday_period) AS SamplesDataAggregates UNPIVOT (value FOR category IN ([Received Samples], [Tested Samples], [Referred Samples])) AS unpvt
ORDER BY
	week_name ASC,
	sort_order