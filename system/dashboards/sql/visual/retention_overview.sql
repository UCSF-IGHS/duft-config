WITH total_count AS (
    SELECT 
        SUM(CASE 
            WHEN fse."Retention Status" IN ('In Care', 'Missed Appointments', 'Treatment Interruptions') 
            THEN 1 ELSE 0 
        END) AS total
    FROM analysis.fact_sentinel_event fse
)
SELECT 
    categories."Retention Status" AS category, 
    COUNT(a."Retention Status") AS value, 
    CASE 
        WHEN total.total = 0 THEN '0%' 
        ELSE CONCAT(
            ROUND((COUNT(a."Retention Status") * 100.0 / NULLIF(total.total, 0)), 1), '%'
        ) 
    END AS percentage
FROM 
    (VALUES ('In Care'), ('Missed Appointments'), ('Treatment Interruptions')) AS categories("Retention Status")
LEFT JOIN 
    analysis.fact_sentinel_event a 
    ON categories."Retention Status" = a."Retention Status"
    AND a."Retention Status" IN ('In Care', 'Missed Appointments', 'Treatment Interruptions')
CROSS JOIN 
    total_count total
GROUP BY 
    categories."Retention Status", total.total
ORDER BY 
    CASE 
        WHEN categories."Retention Status" = 'In Care' THEN 1 
        WHEN categories."Retention Status" = 'Missed Appointments' THEN 2 
        WHEN categories."Retention Status" = 'Treatment Interruptions' THEN 3 
    END;
