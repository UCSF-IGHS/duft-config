SELECT
	category,
	SUM(value) AS value
FROM
	(
	SELECT
		s.report_date,
		s.hvl_samples_with_results_equal_or_above_1000 AS [>=1000 copies],
		s.hvl_samples_with_results_less_than_1000_or_above_50 AS [50-999 copies],
		s.hvl_samples_with_results_less_than_50 AS [<=50 copies]
	FROM
		final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON
		s.report_date = d.date
	WHERE
		s.report_date BETWEEN DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE()) AND DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())) AS SampleData UNPIVOT (value FOR category IN ([>=1000 copies], [50-999 copies], [<=50 copies])) AS unpvt
GROUP BY
	category
ORDER BY
	CASE
		WHEN category = '<=50 copies' THEN 1
		WHEN category = '50-999 copies' THEN 2
		WHEN category = '>=1000 copies' THEN 3
	END;