SELECT
    TRIM(f.region) AS category,
    SUM(s.hpv_sample_received) AS value
FROM
    final.fact_daily_sample_summary s
    INNER JOIN derived.dim_date d 
        ON s.report_date = d.date
    INNER JOIN derived.dim_facility f 
        ON s.hfr_id_for_HUB_sample_is_coming_from = f.hfr_code
WHERE
    s.report_date >= $[start_date%d]
    AND s.report_date <= $[end_date%d]
GROUP BY
    TRIM(f.region)
HAVING
    SUM(s.hpv_sample_received) <> 0
ORDER BY
    TRIM(f.region);
