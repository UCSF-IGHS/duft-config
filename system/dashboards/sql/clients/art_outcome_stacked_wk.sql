SELECT 
    v.category AS category,
    COALESCE(SUM(CASE WHEN gender = 'Male' THEN v.value ELSE 0 END), 0) AS 'Male',
    COALESCE(SUM(CASE WHEN gender = 'Female' THEN v.value ELSE 0 END), 0) AS 'Female'
FROM vw_art_outcomes v
LEFT JOIN (SELECT DISTINCT TRIM(ten_year_interval) as ag FROM dim_age_group) a 
    ON a.ag = v.age_group 
GROUP BY v.category;