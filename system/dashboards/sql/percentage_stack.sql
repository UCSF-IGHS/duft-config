WITH all_combinations AS 
(
    SELECT DISTINCT r.first_art_regimen,a.ten_year_interval as age_group,  0 AS tot 
    FROM (SELECT DISTINCT TRIM(ten_year_interval) AS ten_year_interval FROM dim_age_group) a 
    CROSS JOIN (SELECT DISTINCT first_art_regimen FROM fact_sentinel_event) r
),
actual_results AS 
(
    SELECT TRIM(ag.ten_year_interval) AS age_group, gender, se.first_art_regimen,COUNT(*) AS tot 
    FROM fact_sentinel_event se 
    INNER JOIN dim_client c ON se.client_id=c.client_id 
    INNER JOIN dim_age_group ag ON c.current_age=ag.age GROUP BY ag.ten_year_interval,se.first_art_regimen, gender
) 
SELECT 
    COALESCE(ar.first_art_regimen,ac.first_art_regimen) AS category,
    COALESCE(SUM(CASE WHEN ar.age_group='0-9' THEN ar.tot ELSE 0 END),0) AS '0-9',
    COALESCE(SUM(CASE WHEN ar.age_group='10-19' THEN ar.tot ELSE 0 END),0) AS '10-19',
    COALESCE(SUM(CASE WHEN ar.age_group='20-29' THEN ar.tot ELSE 0 END),0) AS '20-29',
    COALESCE(SUM(CASE WHEN ar.age_group='30-39' THEN ar.tot ELSE 0 END),0) AS '30-39',
    COALESCE(SUM(CASE WHEN ar.age_group='40-49' THEN ar.tot ELSE 0 END),0) AS '40-49',
    COALESCE(SUM(CASE WHEN ar.age_group='50-59' THEN ar.tot ELSE 0 END),0) AS '50-59',
    COALESCE(SUM(CASE WHEN ar.age_group='60-69' THEN ar.tot ELSE 0 END),0) AS '60-69',
    COALESCE(SUM(CASE WHEN ar.age_group='70+' THEN ar.tot ELSE 0 END),0) AS '70+' 
FROM all_combinations ac 
LEFT JOIN actual_results ar ON ar.first_art_regimen=ac.first_art_regimen AND ar.age_group=ac.age_group 
WHERE (gender = '$gender' OR '$gender' = '') AND (ar.age_group = '$age_group' OR '$age_group' = '')
GROUP BY ac.first_art_regimen ORDER BY ac.first_art_regimen
                  