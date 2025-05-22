WITH hvl_pending_results AS (
SELECT
	hvl_results_pending
FROM
	(
	SELECT
		fdss.report_date,
		SUM(fdss.hvl_result_pending) AS hvl_results_pending,
		RANK() OVER (
		ORDER BY fdss.report_date) AS day_number
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
            hvl_backlog_before_reporting AS (
SELECT
	SUM(hvl_sample_collected) - SUM(hvl_sample_tested) AS [Backlog at beginning of reporting period]
FROM
	[final].fact_daily_sample_summary
WHERE
	report_date < $[start_date%d]
            ),
            hvl_backlog_after_reporting AS (
SELECT
	SUM(hvl_sample_collected) - SUM(hvl_sample_tested) AS [Backlog at end of reporting period]
FROM
	[final].fact_daily_sample_summary
WHERE
	report_date <= $[end_date%d]
            ),
            hvl_report_table AS (
SELECT
	SUM(hvl_sample_received) AS [Sample Received],
	SUM(hvl_sample_rejected) AS [Sample Rejected],
	SUM(hvl_sample_tested) AS [Sample Tested],
	SUM(hvl_result_tnd) AS [TND],
	SUM(hvl_samples_with_results_equal_or_above_1000) AS [VL>1000],
	SUM(hvl_samples_with_results_less_than_1000_or_above_50) + SUM(hvl_samples_with_results_less_than_50) AS [VL<1000],
	SUM(hvl_result_invalid) AS [Aborted/Invalid/Clot],
	SUM(hvl_result_authorized) AS [Results Authorized]
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
	mt.[TND],
	mt.[VL<1000],
	mt.[VL>1000],
	mt.[Aborted/Invalid/Clot],
	be.[Backlog at end of reporting period],
	mt.[Results Authorized],
	pr.hvl_results_pending AS [Results pending Authorization]
FROM
	hvl_pending_results pr
CROSS JOIN hvl_report_table mt
CROSS JOIN hvl_backlog_before_reporting bb
CROSS JOIN hvl_backlog_after_reporting be