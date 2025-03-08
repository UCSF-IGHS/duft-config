SELECT 
    v.category AS category,
    COALESCE(SUM(CASE WHEN a.ag = '0-9' THEN v.value ELSE 0 END), 0) AS '0-9',
    COALESCE(SUM(CASE WHEN a.ag = '10-19' THEN v.value ELSE 0 END), 0) AS '10-19',
    COALESCE(SUM(CASE WHEN a.ag = '20-29' THEN v.value ELSE 0 END), 0) AS '20-29',
    COALESCE(SUM(CASE WHEN a.ag = '30-39' THEN v.value ELSE 0 END), 0) AS '30-39',
    COALESCE(SUM(CASE WHEN a.ag = '40-49' THEN v.value ELSE 0 END), 0) AS '40-49',
    COALESCE(SUM(CASE WHEN a.ag = '50-59' THEN v.value ELSE 0 END), 0) AS '50-59',
		COALESCE(SUM(CASE WHEN a.ag = '60-69' THEN v.value ELSE 0 END), 0) AS '60-69',
		COALESCE(SUM(CASE WHEN a.ag = '70+' THEN v.value ELSE 0 END), 0) AS '70+'
FROM vw_art_outcomes v
LEFT JOIN (SELECT DISTINCT TRIM(ten_year_interval) as ag FROM dim_age_group) a 
    ON a.ag = v.age_group 
GROUP BY v.category;