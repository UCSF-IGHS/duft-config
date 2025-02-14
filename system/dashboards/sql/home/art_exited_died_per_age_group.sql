SELECT
	TRIM( year ) AS category,
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '0-9' THEN 1 ELSE 0 END ) AS '0-9',
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '10-19' THEN 1 ELSE 0 END ) AS '10-19' ,
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '20-29' THEN 1 ELSE 0 END ) AS '20-29',
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '30-39' THEN 1 ELSE 0 END ) AS '30-39' ,
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '40-49' THEN 1 ELSE 0 END ) AS '40-49',
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '50-59' THEN 1 ELSE 0 END ) AS '50-59' ,
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '60-69' THEN 1 ELSE 0 END ) AS '60-69',
	SUM( CASE WHEN TRIM(ag.ten_year_interval) = '70+' THEN 1 ELSE 0 END ) AS '70+' 
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