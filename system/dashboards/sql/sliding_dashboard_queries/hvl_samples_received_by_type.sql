WITH
	DateRange AS (
		SELECT
			DATEADD (
				DAY,
				- (DATEPART (WEEKDAY, GETDATE ()) + 6),
				GETDATE ()
			) AS firstDay,
			DATEADD (
				DAY,
				1 - DATEPART (WEEKDAY, GETDATE ()),
				GETDATE ()
			) AS lastDay
	)
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
			CROSS JOIN DateRange
		WHERE
			s.report_date >= firstDay
			AND s.report_date <= lastDay
	) AS SampleData UNPIVOT (value FOR category IN (Wholeblood, Plasma)) AS unpvt
GROUP BY
	category;