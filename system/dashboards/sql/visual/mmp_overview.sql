WITH total_count AS (
    SELECT SUM(CASE WHEN fse."MMP Status" IS NOT NULL AND fse."TX Curr" = 'Yes' THEN 1 ELSE 0 END) AS total 
    FROM analysis.fact_sentinel_event fse
)
SELECT 
    categories."MMP Status" AS category, 
    COUNT(a."MMP Status") AS value, 
    CASE 
        WHEN total.total = 0 THEN '0%' 
        ELSE CONCAT(
            ROUND((COUNT(a."MMP Status") * 100.0 / NULLIF(total.total, 0)), 1), '%'
        ) 
    END AS percentage
FROM 
    (VALUES ('< 3 MMP'), ('3-5 MMP'), ('6+ MMP')) AS categories("MMP Status")
LEFT JOIN 
    analysis.fact_sentinel_event a 
    ON categories."MMP Status" = a."MMP Status"
    AND a."TX Curr" = 'Yes'
    AND a."MMP Status" IS NOT NULL
CROSS JOIN 
    total_count total
GROUP BY 
    categories."MMP Status", total.total
ORDER BY 
    CASE 
        WHEN categories."MMP Status" = '< 3 MMP' THEN 3 
        WHEN categories."MMP Status" = '3-5 MMP' THEN 2 
        WHEN categories."MMP Status" = '6+ MMP' THEN 1 
    END