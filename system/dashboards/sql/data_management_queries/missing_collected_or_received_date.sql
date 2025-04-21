SELECT
	dim_facility.region AS Region,
	dim_facility.district AS Council,
	dim_facility.facility_name AS Facility,
	dim_facility.hfr_code AS HFR,
	dim_samples.test_name AS [Test Name],
	dim_samples.sample_tracking_id AS [Sample ID],
	dim_samples.sample_quality_status AS [Sample Status],
	dim_samples.collected_date AS [Collected Date],
	dim_samples.lab_received_date AS [Received Date],
	dim_samples.tested_date AS [Tested Date],
	dim_samples.result_dispatched_date AS [Result Date],
	dim_samples.[result] AS [Results],
	dim_samples.cleaning_comment AS [Data Issue]
FROM
	[derived].dim_sample AS dim_samples
LEFT JOIN [derived].dim_facility AS dim_facility ON
	dim_samples.hub_facility_id = dim_facility.facility_id
WHERE
	REPLACE(dim_samples.cleaning_comment, ' ', '') = 'MissingCollectedOrReceivedDate';