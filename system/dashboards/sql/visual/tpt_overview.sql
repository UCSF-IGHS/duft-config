WITH total_count AS (
    SELECT SUM(CASE WHEN fse."TPT Status Two" IS NOT NULL AND fse."TX Curr" = 'Yes' THEN 1 ELSE 0 END) AS total 
    FROM analysis.fact_sentinel_event fse
)
SELECT 
    categories."TPT Status Two" AS category, 
    COUNT(a."TPT Status Two") AS value, 
    CASE 
        WHEN total.total = 0 THEN '0%' 
        ELSE CONCAT(
            ROUND((COUNT(a."TPT Status Two") * 100.0 / NULLIF(total.total, 0)), 1), '%'
        ) 
    END AS percentage
FROM 
    (VALUES ('TPT completed'), ('Currently on TPT/TBT'), ('Incomplete TPT')) AS categories("TPT Status Two")
LEFT JOIN 
    analysis.fact_sentinel_event a 
    ON categories."TPT Status Two" = a."TPT Status Two"
    AND a."TX Curr" = 'Yes'
    AND a."TPT Status Two" IS NOT NULL
CROSS JOIN 
    total_count total
GROUP BY 
    categories."TPT Status Two", total.total
ORDER BY 
    CASE 
        WHEN categories."TPT Status Two" = 'TPT completed' THEN 1 
        WHEN categories."TPT Status Two" = 'Currently on TPT/TBT' THEN 2 
        WHEN categories."TPT Status Two" = 'Incomplete TPT' THEN 3 
    END;
