SELECT
	SUM(hvl_sample_received) AS [Sample Received],
	SUM(hvl_sample_rejected) AS [Sample Rejected],
	SUM(hvl_sample_tested) AS [Sample Tested],
	SUM(hvl_result_tnd) AS TND,
	SUM(hvl_samples_with_results_less_than_1000_or_above_50) + SUM(hvl_samples_with_results_less_than_50) AS [VL<1000],
	SUM(hvl_samples_with_results_equal_or_above_1000) AS [VL>1000],
	SUM(hvl_result_invalid) AS [Aborted/Clot/Invalid],
	SUM(hvl_result_authorized) AS [Results Authorized],
    SUM(hvl_result_pending) AS [Results pending Authorization]
FROM
	[final].fact_daily_sample_summary fdss
INNER JOIN [derived].dim_date d ON
	fdss.report_date = d.date
