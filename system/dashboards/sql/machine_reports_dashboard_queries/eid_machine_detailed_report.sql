WITH sample_received AS (
    SELECT
        fd.report_date,
        SUM(fd.eid_sample_dbs_received) AS [eid_received]
    FROM
        [final].fact_daily_sample_summary fd
        INNER JOIN
        [derived].dim_date d
        ON fd.report_date = d.date
    WHERE 
        d.date >= $[start_date%d]
        AND d.date <= $[end_date%d]
    GROUP BY 
        fd.report_date
)

SELECT fd.report_date AS date,
    dd.original_device_name AS equipment_name,
    CASE 
        WHEN fd.is_active = 1 THEN 'Working'
        ELSE 'Break down'
    END AS equipment_functionality_status,
    sr.eid_received AS eid_samples_received,
    dd.device_capacity AS [capacity-24hrs(tests)],
    ISNULL(fd.eid_samples_tested, 0) AS eid_samples_tested,
    fd.eid_utilization_percent AS [%capacity utilized for eid testing],
    fd.eid_samples_pending AS current_eid_pending_samples
FROM [derived].fact_daily_device_status fd
    INNER JOIN sample_received sr ON sr.report_date = fd.report_date
    INNER JOIN [derived].dim_device dd ON fd.device_id = dd.device_id
WHERE
    fd.report_date >= $[start_date%d]
    AND fd.report_date <= $[end_date%d]
    AND dd.is_eid_device =1
ORDER BY fd.report_date DESC