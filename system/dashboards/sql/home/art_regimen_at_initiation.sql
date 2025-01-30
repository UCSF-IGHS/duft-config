SELECT 
    first_art_regimen AS category,
    SUM(CASE WHEN a.age_group = '0-9' THEN value ELSE 0 END) AS '0-9',
		SUM(CASE WHEN a.age_group = '10-19' THEN value ELSE 0 END) AS '10-19', 
		SUM(CASE WHEN a.age_group = '20-29' THEN value ELSE 0 END) AS '20-29', 
		SUM(CASE WHEN a.age_group = '30-39' THEN value ELSE 0 END) AS '30-39',
		SUM(CASE WHEN a.age_group = '40-49' THEN value ELSE 0 END) AS '40-49', 
		SUM(CASE WHEN a.age_group = '50-59' THEN value ELSE 0 END) AS '50-59', 
		SUM(CASE WHEN a.age_group = '60-69' THEN value ELSE 0 END) AS '60-69', 
		SUM(CASE WHEN a.age_group = '70+' THEN value ELSE 0 END) AS '70+'
FROM (SELECT DISTINCT TRIM(ten_year_interval) as age_group FROM dim_age_group) a
INNER JOIN vw_art_regimen_lines v 
    ON a.age_group = v.age_group 
    AND (gender = '$gender' OR '$gender' = '') 
    AND (v.age_group = '$age_group' OR '$age_group' = '') 
    AND (year = COALESCE(NULLIF('$year', ''), '2021'))
GROUP BY first_art_regimen
