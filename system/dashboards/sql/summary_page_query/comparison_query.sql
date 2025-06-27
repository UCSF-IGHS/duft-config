SELECT 
    category,
    SUM(source_value) AS [Data from Source],
    SUM(analysis_value) AS [Lab Visual Data],
    SUM(difference) AS [Difference]
FROM 
    [final].data_comparison dc
WHERE 
    report_date BETWEEN $[start_date%d] AND $[end_date%d]
GROUP BY
    category
ORDER BY 
    CASE category
        WHEN 'Collected Samples' THEN 1
        WHEN 'Received Samples' THEN 2
        WHEN 'Tested Samples' THEN 3
        WHEN 'Authorized/dispatched samples' THEN 4
        ELSE 5
    END;
