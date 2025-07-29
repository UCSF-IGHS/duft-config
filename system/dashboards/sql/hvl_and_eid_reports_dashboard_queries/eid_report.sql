WITH eid_pending_results AS (
	SELECT
		dbs_results_pending
	FROM (
		SELECT
			fdss.report_date,
			SUM(fdss.eid_result_pending) AS dbs_results_pending,
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
eid_backlog_before_reporting AS (
	SELECT 
		CASE 
			WHEN [Backlog at beginning of reporting period] < 0 THEN 0
			ELSE [Backlog at beginning of reporting period]
		END AS [Backlog at beginning of reporting period]
	FROM (
		SELECT
			SUM(eid_sample_dbs_received) - (SUM(eid_sample_tested) + SUM(eid_sample_rejected)) AS [Backlog at beginning of reporting period]
		FROM
			[final].fact_daily_sample_summary
		WHERE
			report_date < $[start_date%d]
	) AS backlog_before_reporting
),
eid_backlog_after_reporting AS (
	SELECT 
		CASE 
			WHEN [Backlog at beginning of reporting period] < 0 THEN 0
			ELSE [Backlog at beginning of reporting period]
		END AS [Backlog at end of reporting period]
	FROM (
		SELECT
			SUM(eid_sample_dbs_received) - (SUM(eid_sample_tested) + SUM(eid_sample_rejected)) AS [Backlog at beginning of reporting period]
		FROM
			[final].fact_daily_sample_summary
		WHERE
			report_date < $[end_date%d]
	) AS backlog_after_reporting
),
eid_report_table AS (
	SELECT
		SUM(eid_sample_dbs_received) AS [Sample Received],
		SUM(eid_sample_rejected) AS [Sample Rejected],
		SUM(eid_sample_tested) AS [Sample Tested],
		SUM(eid_sample_tested_negative) AS [Tested Negative],
		SUM(eid_sample_tested_positive) AS [Tested Positive],
		SUM(result_indeterminate) AS [Indeterminate],
		SUM(eid_result_authorized) AS [Results Authorized]
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
	mt.[Sample Received],
	mt.[Sample Rejected],
	mt.[Sample Tested],
	mt.[Tested Negative],
	mt.[Tested Positive],
	mt.[Indeterminate],
	be.[Backlog at end of reporting period],
	mt.[Results Authorized],
	pr.dbs_results_pending AS [Results pending Authorization]
FROM
	eid_pending_results pr
CROSS JOIN eid_report_table mt
CROSS JOIN eid_backlog_before_reporting bb
CROSS JOIN eid_backlog_after_reporting be;
