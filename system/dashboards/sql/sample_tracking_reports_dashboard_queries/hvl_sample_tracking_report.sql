SELECT
	dim_facility.region AS Region,
	dim_facility.council AS Council,
	dim_facility.facility_name AS Facility,
	fact_daily_hvl_sample_status._hfr_id AS HFR,
	dim_sample.sample_tracking_id AS [Sample Tracking ID],
	dim_sample.sample_quality_status AS [Sample Quality Status],
	dim_sample.collected_date AS [Collected Date],
	dim_sample.lab_received_date AS [Received Date],
	dim_sample.tested_date AS [Tested Date],
	dim_sample.result_authorized_date AS [Result Date],
	fact_daily_hvl_sample_status.result AS Results
FROM
	(
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY sample_testing_id
	ORDER BY
		collected_date DESC) AS sample_rank
	FROM
		[derived].fact_sample_testing
	where
		is_hvl_sample = 1) AS fact_daily_hvl_sample_status
JOIN (
	Select
		*
	from
		[derived].fact_sample_testing fst
	where
		fst.is_hvl_sample = 1
) AS dim_sample ON
	fact_daily_hvl_sample_status.sample_testing_id = dim_sample.sample_testing_id
JOIN [derived].dim_facility AS dim_facility ON
	fact_daily_hvl_sample_status._hfr_id = dim_facility.hfr_code
WHERE
	fact_daily_hvl_sample_status.sample_rank = 1
ORDER BY
	dim_sample.lab_received_date DESC
