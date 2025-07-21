SELECT
	category,
	SUM(value) AS value
FROM
	(
		SELECT
			s.report_date,
			s.hvl_sample_wholeblood_received AS Wholeblood,
			s.hvl_sample_plasma_received AS Plasma
		FROM
			final.fact_daily_sample_summary s
			INNER JOIN derived.dim_date d ON s.report_date = d.date
		WHERE
			s.report_date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
			AND s.report_date <= DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
	) AS SampleData 
UNPIVOT (value FOR category IN (Wholeblood, Plasma)) AS unpvt
GROUP BY
	category;