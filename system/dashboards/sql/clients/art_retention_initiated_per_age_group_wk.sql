SELECT  
    a.age_group AS category, 
    COALESCE(b.Male, 0) AS Male, 
    COALESCE(b.Female, 0) AS Female
FROM 
    (SELECT DISTINCT TRIM(ten_year_interval) AS age_group FROM dim_age_group) a
LEFT JOIN 
    (
        SELECT
            TRIM(ag.ten_year_interval) AS ag,
            SUM(CASE WHEN c.gender = 'Male' THEN 1 ELSE 0 END) AS Male,
            SUM(CASE WHEN c.gender = 'Female' THEN 1 ELSE 0 END) AS Female
        FROM fact_sentinel_event se
        INNER JOIN dim_client c ON se.client_id = c.client_id
        INNER JOIN dim_age_group ag ON c.current_age = ag.age 
        WHERE has_ever_been_initiated_on_art = 1 
        GROUP BY TRIM(ag.ten_year_interval)
    ) b
ON a.age_group = b.ag
ORDER BY a.age_group;