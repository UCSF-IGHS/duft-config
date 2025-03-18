SELECT categories."TPT Status" AS category, COUNT(a."TPT Status") AS value, CASE WHEN (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "TPT Status Two" IS NOT NULL AND "Current Age" <= 19 AND "TX Curr" = 'Yes') = 0 THEN '0%' ELSE CONCAT(ROUND((COUNT(a."TPT Status") * 100.0 / (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "TPT Status Two" IS NOT NULL AND "Current Age" <= 19 AND "TX Curr" = 'Yes')), 1), '%') END AS percentage FROM (SELECT 'TPT completed' AS "TPT Status" UNION ALL SELECT 'Currently on TPT/TBT' UNION ALL SELECT 'Incomplete TPT') AS categories LEFT JOIN (SELECT "TPT Status Two" AS "TPT Status", "Sex" AS "Sex", "Tri Pillar Age Group" AS age_group FROM analysis.fact_sentinel_event WHERE "TX Curr" = 'Yes' AND "Current Age" <= 19 AND "TPT Status Two" IS NOT NULL) a ON categories."TPT Status" = a."TPT Status" GROUP BY categories."TPT Status" ORDER BY CASE WHEN categories."TPT Status" = 'TPT completed' THEN 1 WHEN categories."TPT Status" = 'Currently on TPT/TBT' THEN 2 WHEN categories."TPT Status" = 'Incomplete TPT' THEN 3 END;