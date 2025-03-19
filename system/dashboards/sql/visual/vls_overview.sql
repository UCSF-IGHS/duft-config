WITH total_count AS (
    SELECT 
        SUM(CASE 
            WHEN fse."__client_id" NOT IN (
                SELECT "__client_id" 
                FROM analysis.active_clients 
            ) 
            AND fse."Last Viral Load Result Category" IS NOT NULL 
            AND fse."Viral Load Eligibility" IN ('Monitored per Guidelines', 'Slightly Delayed') 
        THEN 1 ELSE 0 
        END) AS total
    FROM analysis.fact_sentinel_event fse
)
SELECT 
    categories.DATA AS category, 
    COUNT(a."Last Viral Load Result Category") AS value, 
    CASE 
        WHEN total.total = 0 THEN '0%' 
        ELSE CONCAT(
            ROUND((COUNT(a."Last Viral Load Result Category") * 100.0 / NULLIF(total.total, 0)), 1), '%'
        ) 
    END AS percentage
FROM 
    (VALUES ('Undetectable'), ('LLV'), ('Unsuppressed')) AS categories(DATA)
LEFT JOIN 
    analysis.fact_sentinel_event a 
    ON categories.DATA = a."Last Viral Load Result Category"
    AND a."__client_id" NOT IN (
        SELECT "__client_id" 
				FROM analysis.active_clients 
    )
    AND a."Last Viral Load Result Category" IS NOT NULL
    AND a."Viral Load Eligibility" IN ('Monitored per Guidelines', 'Slightly Delayed')
CROSS JOIN 
    total_count total
GROUP BY 
    categories.DATA, total.total
ORDER BY 
    CASE 
        WHEN categories.DATA = 'Undetectable' THEN 1 
        WHEN categories.DATA = 'LLV' THEN 2 
        WHEN categories.DATA = 'Unsuppressed' THEN 3 
    END