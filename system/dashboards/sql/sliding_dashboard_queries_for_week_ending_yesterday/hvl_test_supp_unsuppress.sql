SELECT
	category,
	SUM(value) AS value
FROM
	(
	SELECT
		s.report_date,
		s.hvl_samples_with_results_equal_or_above_1000 AS [>=1000 copies],
		s.hvl_samples_with_results_equal_or_above_1000 AS [Unsuppressed],
		(s.hvl_samples_with_results_less_than_1000_or_above_50 +
		s.hvl_samples_with_results_less_than_50 +
		s.hvl_result_tnd) AS [Suppressed]
	FROM
		final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON
		s.report_date = d.date
	WHERE
		s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) 
		AND s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
	) AS SampleData UNPIVOT (value FOR category IN ([Unsuppressed], [Suppressed])) AS unpvt
GROUP BY
	category
ORDER BY category DESC