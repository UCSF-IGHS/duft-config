SELECT  
    a.age_group AS category, 
    COALESCE(b.Male, 0) AS Male, 
    COALESCE(b.Female, 0) AS Female
FROM 
    (SELECT DISTINCT TRIM(ten_year_interval) AS age_group FROM dim_age_group) a
LEFT JOIN 
    (
        SELECT
            TRIM(ag.ten_year_interval) AS age_group,
            SUM(CASE WHEN c.gender = 'Male' THEN 1 ELSE 0 END) AS Male,
            SUM(CASE WHEN c.gender = 'Female' THEN 1 ELSE 0 END) AS Female
        FROM fact_sentinel_event se
        INNER JOIN dim_client c ON se.client_id = c.client_id
        INNER JOIN dim_age_group ag ON c.current_age = ag.age 
        WHERE
            has_ever_been_initiated_on_art = 1 
            AND (gender = '$gender' OR '$gender' = '') AND 
			(TRIM(ag.ten_year_interval) = '$age_group' OR '$age_group' = '') AND 
			(strftime('%Y', hiv_diagnosis_date) = COALESCE(NULLIF('$year', ''), '2021'))
        GROUP BY TRIM(ag.ten_year_interval)
    ) b
ON a.age_group = b.age_group
ORDER BY a.age_group;