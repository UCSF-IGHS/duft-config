SELECT
	TRIM( year ) AS category,
	SUM( CASE WHEN gender = 'Male' THEN 1 ELSE 0 END ) AS Male,
	SUM( CASE WHEN gender = 'Female' THEN 1 ELSE 0 END ) AS Female 
FROM
	fact_sentinel_event se
	INNER JOIN dim_client c ON se.client_id = c.client_id
	INNER JOIN dim_date d ON se.hiv_diagnosis_date = d.full_date 
    INNER JOIN dim_age_group ag ON c.current_age = ag.age
WHERE
	year BETWEEN 2006 AND 2023 
	AND has_exited_died = 1 
    AND (gender = '$gender' OR '$gender' = '') 
    AND (TRIM(ag.ten_year_interval) = '$age_group' OR '$age_group' = '')
GROUP BY
	TRIM( year ) 
ORDER BY
	TRIM( year )