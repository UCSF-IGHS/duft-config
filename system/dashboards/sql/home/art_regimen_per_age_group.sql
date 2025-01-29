SELECT 
    a.age_group AS category,
    COALESCE(SUM(CASE WHEN v.category = 'First line' THEN v.value ELSE 0 END), 0) AS 'First line',
    COALESCE(SUM(CASE WHEN v.category = 'Second line' THEN v.value ELSE 0 END), 0) AS 'Second line',
    COALESCE(SUM(CASE WHEN v.category = 'Third line' THEN v.value ELSE 0 END), 0) AS 'Third line',
    COALESCE(SUM(CASE WHEN v.category = 'Unknown line' THEN v.value ELSE 0 END), 0) AS 'Unknown line'
FROM (SELECT DISTINCT TRIM(ten_year_interval) as age_group FROM dim_age_group) a
LEFT JOIN vw_art_regimen_lines v 
    ON a.age_group = v.age_group 
    AND (gender = '$gender' OR '$gender' = '') 
    AND (v.age_group = '$age_group' OR '$age_group' = '') 
    AND (year = COALESCE(NULLIF('$year', ''), '2021'))
GROUP BY a.age_group
