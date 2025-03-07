SELECT 
    a.ag AS category,
    COALESCE(SUM(CASE WHEN v.category = 'First line' THEN v.value ELSE 0 END), 0) AS 'First line',
    COALESCE(SUM(CASE WHEN v.category = 'Second line' THEN v.value ELSE 0 END), 0) AS 'Second line',
    COALESCE(SUM(CASE WHEN v.category = 'Third line' THEN v.value ELSE 0 END), 0) AS 'Third line',
    COALESCE(SUM(CASE WHEN v.category = 'Unknown line' THEN v.value ELSE 0 END), 0) AS 'Unknown line'
FROM (SELECT DISTINCT TRIM(ten_year_interval) as ag FROM dim_age_group) a
LEFT JOIN vw_art_regimen_lines v 
    ON a.ag = v.age_group  
GROUP BY a.ag