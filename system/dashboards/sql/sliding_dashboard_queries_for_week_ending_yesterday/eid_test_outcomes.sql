SELECT
	category,
	SUM(value) AS value
FROM
	(
		SELECT
			SUM(s.eid_sample_tested_positive) AS Positive,
			SUM(s.eid_sample_tested_negative) AS Negative,
			SUM(s.eid_result_failed) AS Failed
		FROM
			final.fact_daily_sample_summary s
			INNER JOIN derived.dim_date d ON s.report_date = d.date
		WHERE
			s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) 
			AND s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
	) AS SampleData UNPIVOT (
		value FOR category IN (Positive, Negative, Failed)
	) AS unpvt
GROUP BY
	category
ORDER BY
	CASE category
		WHEN 'Positive' THEN 1
		WHEN 'Negative' THEN 2
		WHEN 'Failed' THEN 3
		ELSE 4
	END;