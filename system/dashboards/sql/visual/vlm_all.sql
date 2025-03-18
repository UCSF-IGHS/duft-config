SELECT categories.DATA AS category, COUNT(a.DATA) AS value, CASE WHEN (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "Viral Load Eligibility" IN ('Monitored per Guidelines', 'Delayed', 'Slightly Delayed') AND "TX Curr" = 'Yes') = 0 THEN '0%' ELSE CONCAT(ROUND((COUNT(a.DATA) * 100.0 / (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "Viral Load Eligibility" IN ('Monitored per Guidelines', 'Delayed', 'Slightly Delayed') AND "TX Curr" = 'Yes')), 1), '%') END AS percentage FROM (SELECT 'Monitored per Guidelines' AS DATA UNION ALL SELECT 'Slightly Delayed' UNION ALL SELECT 'Delayed') AS categories LEFT JOIN (SELECT "Sex" AS "Sex", "Tri Pillar Age Group" AS age_group, "Viral Load Eligibility" AS DATA, "__client_id" FROM analysis.fact_sentinel_event WHERE "TX Curr" = 'Yes' AND "Viral Load Eligibility" IN ('Monitored per Guidelines', 'Delayed', 'Slightly Delayed')) a ON categories.DATA = a.DATA GROUP BY categories.DATA ORDER BY CASE WHEN categories.DATA = 'Monitored per Guidelines' THEN 1 WHEN categories.DATA = 'Slightly Delayed' THEN 2 WHEN categories.DATA = 'Delayed' THEN 3 END