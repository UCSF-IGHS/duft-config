WITH hpv_pending_results AS (
	SELECT
		hpv_results_pending
	FROM (
		SELECT
			fdss.report_date,
		SUM(fdss.hpv_result_pending) AS hpv_results_pending,
			RANK() OVER (ORDER BY fdss.report_date) AS day_number
		FROM
			[final].fact_daily_sample_summary fdss
		INNER JOIN [derived].dim_date d ON
			fdss.report_date = d.date
		WHERE
			[date] >= $[start_date%d]
			AND [date] <= $[end_date%d]
		GROUP BY
			fdss.report_date
	) AS subquery
	WHERE
		day_number = DATEDIFF(day, $[start_date%d], $[end_date%d]) + 1
),
hpv_backlog_before_reporting AS (
	SELECT 
		CASE 
			WHEN [Backlog at beginning of reporting period] < 0 THEN 0
			ELSE [Backlog at beginning of reporting period]
		END AS [Backlog at beginning of reporting period]
	FROM (
		SELECT
			SUM(hpv_sample_received) - (SUM(hpv_sample_tested) + SUM(hpv_sample_rejected)) AS [Backlog at beginning of reporting period]
		FROM
			[final].fact_daily_sample_summary
		WHERE
			report_date < $[start_date%d]
	) AS backlog_before_reporting
),
hpv_backlog_after_reporting AS (
	SELECT 
		CASE 
			WHEN [Backlog at end of reporting period] < 0 THEN 0
			ELSE [Backlog at end of reporting period]
		END AS [Backlog at end of reporting period]
	FROM (
		SELECT
			SUM(hpv_sample_received) - (SUM(hpv_sample_tested) + SUM(hpv_sample_rejected)) AS [Backlog at end of reporting period]
		FROM
			[final].fact_daily_sample_summary
		WHERE
			report_date < $[end_date%d]
	) AS backlog_after_reporting
),
hpv_report_table AS (
	SELECT
		SUM(hpv_sample_received) AS [Samples Received],
		SUM(hpv_sample_rejected) AS [Samples Rejected],
		SUM(hpv_sample_tested) AS [Samples Tested],
		SUM(hpv_result_failed) AS [Failed],
		SUM(hpv_sample_tested_positive) AS [Positive],
		SUM(hpv_sample_tested_negative) AS [Negative],
		SUM(hpv_result_invalid) AS [Invalid],
		SUM(hpv_result_authorized) AS [Results Authorized]
	FROM
		[final].fact_daily_sample_summary fdss
	INNER JOIN [derived].dim_date d ON
		fdss.report_date = d.date
	WHERE
		[date] >= $[start_date%d]
		AND [date] <= $[end_date%d]
)
SELECT
	bb.[Backlog at beginning of reporting period],
	mt.[Samples Received],
	mt.[Samples Rejected],
	mt.[Samples Tested],
	mt.[Results Authorized],
	mt.[Positive],
	mt.[Negative],
	mt.[Failed],
	mt.[Invalid],
	pr.hpv_results_pending AS [Results pending authorization],
	be.[Backlog at end of reporting period]
FROM
	hpv_pending_results pr
CROSS JOIN hpv_report_table mt
CROSS JOIN hpv_backlog_before_reporting bb
CROSS JOIN hpv_backlog_after_reporting be;
