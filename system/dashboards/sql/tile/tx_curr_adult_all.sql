SELECT COUNT(*) AS value, CASE WHEN (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "TX Curr" = 'Yes') = 0 THEN '0%' ELSE ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM analysis.fact_sentinel_event WHERE "TX Curr" = 'Yes'), 1) || '%' END AS proportion FROM analysis.fact_sentinel_event 
WHERE "Tri Pillar Age Group" IN ('20-39','40+') 
AND "TX Curr" = 'Yes'