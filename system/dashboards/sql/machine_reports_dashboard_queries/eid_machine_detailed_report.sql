WITH
    sample_received
    AS
    (
        SELECT
            fdss.report_date,
            SUM(fdss.eid_sample_dbs_received) AS [eid_received]

        FROM
            [final].fact_daily_sample_summary fdss
            INNER JOIN
            [derived].dim_date d
            ON fdss.report_date = d.date
        WHERE 
        d.date >= $[start_date%d]
        AND d.date <= $[end_date%d]
    GROUP BY 
        fdss.report_date
)

SELECT fdds.report_date AS date,
    dd.original_device_name AS equipment_name,
    CASE 
        WHEN fdds.is_broken IS NULL THEN 'Working'
        ELSE 'Break down'
    END AS equipment_functionality_status,
    sr.eid_received AS eid_samples_received,
    dd.device_capacity AS [capacity-24hrs(tests)],
    ISNULL(fdds.eid_samples_tested, 0) AS eid_samples_tested,
    fdds.eid_utilization_percent AS [%capacity utilized for eid testing],
    fdds.eid_samples_pending AS current_eid_pending_samples
FROM [derived].fact_daily_device_status fdds
    INNER JOIN sample_received sr ON sr.report_date = fdds.report_date
    INNER JOIN [derived].dim_device dd
    ON fdds.device_id = dd.device_id
WHERE fdds.report_date >= $[start_date%d]
  AND fdds.report_date <= $[end_date%d]
  AND dd.is_eid_device =1
ORDER BY fdds.report_date DESC