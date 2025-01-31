SELECT 
    a.age_group AS category,
	COALESCE(SUM(CASE WHEN v.category = 'Case Closed' THEN v.value ELSE 0 END), 0) AS 'Case Closed',
    COALESCE(SUM(CASE WHEN v.category = 'Needs VL Test' THEN v.value ELSE 0 END), 0) AS 'Needs VL Test',
    COALESCE(SUM(CASE WHEN v.category = 'Unknown' THEN v.value ELSE 0 END), 0) AS 'Unknown',
    COALESCE(SUM(CASE WHEN v.category = 'VL Suppressed' THEN v.value ELSE 0 END), 0) AS 'VL Suppressed',
    COALESCE(SUM(CASE WHEN v.category = 'VL Not Suppressed' THEN v.value ELSE 0 END), 0) AS 'VL Not Suppressed',
		COALESCE(SUM(CASE WHEN v.category = 'Less than 6 months on ART' THEN v.value ELSE 0 END), 0) AS 'Less than 6 months on ART'
FROM (SELECT DISTINCT TRIM(ten_year_interval) as age_group FROM dim_age_group) a
LEFT JOIN vw_art_outcomes v 
    ON a.age_group = v.age_group 
    AND (gender = '$gender' OR '$gender' = '') 
    AND (v.age_group = '$age_group' OR '$age_group' = '') 
    AND (year = COALESCE(NULLIF('$year', ''), '2021')) 
GROUP BY a.age_group