SELECT 
    first_art_regimen AS category,
    SUM(CASE WHEN a.ag = '0-9' THEN value ELSE 0 END) AS '0-9',
		SUM(CASE WHEN a.ag = '10-19' THEN value ELSE 0 END) AS '10-19', 
		SUM(CASE WHEN a.ag = '20-29' THEN value ELSE 0 END) AS '20-29', 
		SUM(CASE WHEN a.ag = '30-39' THEN value ELSE 0 END) AS '30-39',
		SUM(CASE WHEN a.ag = '40-49' THEN value ELSE 0 END) AS '40-49', 
		SUM(CASE WHEN a.ag = '50-59' THEN value ELSE 0 END) AS '50-59', 
		SUM(CASE WHEN a.ag = '60-69' THEN value ELSE 0 END) AS '60-69', 
		SUM(CASE WHEN a.ag = '70+' THEN value ELSE 0 END) AS '70+'
FROM (SELECT DISTINCT TRIM(ten_year_interval) as ag FROM dim_age_group) a
INNER JOIN vw_art_regimen_lines v 
    ON a.ag = v.age_group 
    
GROUP BY first_art_regimen