SELECT
    TRIM(f.region) AS Region,
    TRIM(f.council) AS Council,
    TRIM(f.facility_name) AS Facility,
    SUM(s.hvl_sample_received) AS [Samples Received]
FROM
    lab_visual_analysis.final.fact_daily_sample_summary s
    INNER JOIN lab_visual_analysis.derived.dim_facility f ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
    INNER JOIN lab_visual_analysis.derived.fact_sample_testing fst ON s.hfr_id_for_HUB_sample_is_coming_from = fst.[_hfr_id] 
WHERE
	fst.lab_received_date >= $[start_date%d]
    AND fst.lab_received_date <= $[end_date%d]
    AND fst.is_hvl_sample = 1
	AND fst.is_valid_record  = 1
	AND fst.is_received  = 1
GROUP BY
    TRIM(f.region),
    TRIM(f.council),
    TRIM(f.facility_name)
ORDER BY
    Facility ASC;