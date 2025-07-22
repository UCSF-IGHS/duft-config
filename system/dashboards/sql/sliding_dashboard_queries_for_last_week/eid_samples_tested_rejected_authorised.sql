SELECT
	week_name,
	category,
	value,
	ROW_NUMBER() OVER (
	ORDER BY CASE
		category WHEN 'Sample Received' THEN 1
		WHEN 'Sample Tested' THEN 2
		WHEN 'Sample Rejected' THEN 3
		WHEN 'Sample Results Dispatched' THEN 4
	END) AS sort_order
FROM
	(
	SELECT
		d.weekly_start_monday_period AS week_name,
		SUM(s.eid_sample_dbs_received) AS [Sample Received],
		SUM(s.eid_sample_tested) AS [Sample Tested],
		SUM(s.eid_sample_rejected) AS [Sample Rejected],
		SUM(s.eid_result_dispatched) AS [Sample Results Dispatched]
	FROM
		final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON
		s.report_date = d.date
	WHERE
		d.[date] >= DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE())
		AND d.[date] <= DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())
	GROUP BY
		d.weekly_start_monday_period) AS SamplesDataAggregates UNPIVOT (value FOR category IN ([Sample Received], [Sample Tested], [Sample Rejected], [Sample Results Dispatched])) AS unpvt
ORDER BY
	week_name ASC,
	sort_order;