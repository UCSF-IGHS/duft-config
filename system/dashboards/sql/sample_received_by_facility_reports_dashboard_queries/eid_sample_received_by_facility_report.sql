SELECT
    TRIM(f.region) AS Region,
    TRIM(f.council) AS Council,
    TRIM(f.facility_name) AS Facility,
    SUM(s.eid_sample_dbs_received) AS [Samples Received]
FROM
    [final].fact_daily_sample_summary s
    INNER JOIN [derived].dim_facility f ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
WHERE
	s.report_date >= $[start_date%d]
    AND s.report_date <= $[end_date%d]
GROUP BY
    TRIM(f.region),
    TRIM(f.council),
    TRIM(f.facility_name)
HAVING
    SUM(s.eid_sample_dbs_received) <> 0
ORDER BY
    Facility ASC;
