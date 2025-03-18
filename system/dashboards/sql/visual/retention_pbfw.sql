SELECT categories.DATA AS category, COUNT(a.DATA) AS value, CASE WHEN (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE ("Last Pregnancy Status" = 'Yes' OR "Last Breast Feeding" = 'Yes') AND "Retention Status" IN ('In Care','Missed Appointments', 'Treatment Interruptions')) = 0 THEN '0%' ELSE CONCAT(ROUND((COUNT(a.DATA) * 100.0 / (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE ("Last Pregnancy Status" = 'Yes' OR "Last Breast Feeding" = 'Yes') AND "Retention Status" IN ('In Care','Missed Appointments', 'Treatment Interruptions'))), 1), '%') END AS percentage FROM (SELECT 'In Care' AS DATA UNION ALL SELECT 'Missed Appointments' UNION ALL SELECT 'Treatment Interruptions') AS categories LEFT JOIN (SELECT "Tri Pillar Age Group" AS age_group, "Retention Status" AS DATA, "Sex" AS sex FROM analysis.fact_sentinel_event WHERE "Retention Status" IN ('In Care','Missed Appointments', 'Treatment Interruptions') AND ("Last Pregnancy Status" = 'Yes' OR "Last Breast Feeding" = 'Yes') ) a ON categories.DATA = a.DATA GROUP BY categories.DATA ORDER BY CASE WHEN categories.DATA = 'In Care' THEN 1 WHEN categories.DATA = 'Missed Appointments' THEN 2 WHEN categories.DATA = 'Treatment Interruptions' THEN 3 END