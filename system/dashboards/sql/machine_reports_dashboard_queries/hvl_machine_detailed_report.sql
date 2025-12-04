WITH sample_received AS (
    SELECT
        fds.report_date,
        SUM(fds.hvl_sample_received) AS [hvl_received]
    FROM
        [final].fact_daily_sample_summary fds
        INNER JOIN
        [derived].dim_date d
        ON fds.report_date = d.date
    WHERE 
        d.date >= $[start_date%d]
        AND d.date <= $[end_date%d]
    GROUP BY 
        fds.report_date
)

SELECT fd.report_date As date,
    dd.original_device_name AS equipment_name,
    CASE 
        WHEN fd.is_active = 1 THEN 'Working'
        ELSE 'Break down'
    END AS equipment_functionality_status,
    sr.hvl_received AS hvl_samples_received,
    dd.device_capacity AS [capacity-24hrs(tests)],
    ISNULL(fd.hvl_samples_tested, 0) AS hvl_samples_tested,
    fd.hvl_utilization_percent AS [%capacity utilized for hvl testing],
    fd.hvl_samples_pending AS current_hvl_pending_samples
FROM
    [derived].fact_daily_device_status fd
    INNER JOIN
    sample_received sr
    ON sr.report_date = fd.report_date
    INNER JOIN
    [derived].dim_device dd
    ON fd.device_id = dd.device_id
WHERE 
    fd.report_date >= $[start_date%d]
    AND fd.report_date <= $[end_date%d]
    AND dd.is_hvl_device =1
ORDER BY fd.report_date DESC