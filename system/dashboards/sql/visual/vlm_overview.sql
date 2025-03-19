WITH total_count AS (
    SELECT 
        SUM(CASE 
            WHEN fse."Viral Load Eligibility" IN ('Monitored per Guidelines', 'Delayed', 'Slightly Delayed') 
            AND fse."TX Curr" = 'Yes' 
            THEN 1 ELSE 0 
        END) AS total
    FROM analysis.fact_sentinel_event fse
)
SELECT 
    categories.DATA AS category, 
    COUNT(a."Viral Load Eligibility") AS value, 
    CASE 
        WHEN total.total = 0 THEN '0%' 
        ELSE CONCAT(
            ROUND((COUNT(a."Viral Load Eligibility") * 100.0 / NULLIF(total.total, 0)), 1), '%'
        ) 
    END AS percentage
FROM 
    (VALUES ('Monitored per Guidelines'), ('Slightly Delayed'), ('Delayed')) AS categories(DATA)
LEFT JOIN 
    analysis.fact_sentinel_event a 
    ON categories.DATA = a."Viral Load Eligibility"
    AND a."TX Curr" = 'Yes'
    AND a."Viral Load Eligibility" IN ('Monitored per Guidelines', 'Delayed', 'Slightly Delayed')
CROSS JOIN 
    total_count total
GROUP BY 
    categories.DATA, total.total
ORDER BY 
    CASE 
        WHEN categories.DATA = 'Monitored per Guidelines' THEN 1 
        WHEN categories.DATA = 'Slightly Delayed' THEN 2 
        WHEN categories.DATA = 'Delayed' THEN 3 
    END;
