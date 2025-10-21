SELECT
    TRIM(f.region) AS Region,
    TRIM(f.council) AS Council,
    TRIM(f.facility_name) AS Facility,
    SUM(s.hvl_sample_received) AS [Samples Received]
FROM
    lab_visual_analysis.final.fact_daily_sample_summary s
    INNER JOIN lab_visual_analysis.derived.dim_facility f ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
WHERE
	s.report_date >= $[start_date%d]
    AND s.report_date <= $[end_date%d]
GROUP BY
    TRIM(f.region),
    TRIM(f.council),
    TRIM(f.facility_name)
ORDER BY
    Facility ASC;