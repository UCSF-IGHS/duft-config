SELECT 
    * 
FROM 
    [final].data_comparison dc
WHERE 
    report_date BETWEEN '2025-05-20' AND '2025-05-29'
GROUP BY 
    report_date
ORDER BY 
    report_date DESC;