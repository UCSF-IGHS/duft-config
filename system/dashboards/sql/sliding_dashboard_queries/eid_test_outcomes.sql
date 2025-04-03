SELECT
	category,
	SUM(value) AS value
FROM
	(
	SELECT
		s.report_date,
		s.eid_sample_tested_positive AS Positive,
		s.eid_sample_tested_negative AS Negative,
		s.eid_sample_tested_result_not_detected AS Failed
	FROM
		final.fact_daily_sample_summary s
	INNER JOIN derived.dim_date d ON
		s.report_date = d.date
	WHERE
		s.report_date BETWEEN DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 6), GETDATE()) AND DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE())) AS SampleData UNPIVOT (value FOR category IN (Positive, Negative, Failed)) AS unpvt
GROUP BY
	category
ORDER BY
	CASE
		category WHEN 'Positive' THEN 1
		WHEN 'Negative' THEN 2
		WHEN 'Failed' THEN 3
		ELSE 4
	END;