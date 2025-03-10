SELECT
	TRIM( year ) AS category,
	SUM( CASE WHEN age_group = '0-9' AND has_exited_died = 1 THEN 1 ELSE 0 END ) AS '0-9',
	SUM( CASE WHEN age_group = '10-19' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '10-19' ,
	SUM( CASE WHEN age_group = '20-29' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '20-29',
	SUM( CASE WHEN age_group = '30-39' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '30-39' ,
	SUM( CASE WHEN age_group = '40-49' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '40-49',
	SUM( CASE WHEN age_group = '50-59' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '50-59' ,
	SUM( CASE WHEN age_group = '60-69' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '60-69',
	SUM( CASE WHEN age_group = '70+' AND has_exited_died = 1  THEN 1 ELSE 0 END ) AS '70+' 
FROM
	fact_sentinel_event se
	INNER JOIN dim_client c ON se.client_id = c.client_id
	INNER JOIN (SELECT d.*
        FROM dim_date d
        JOIN (SELECT DATE('now', '-14 years') AS min_date) AS filter_dates
        ON DATE(d.full_date) >= filter_dates.min_date
    ) d ON se.hiv_diagnosis_date = d.full_date
    INNER JOIN (select age, TRIM(ten_year_interval) as age_group from dim_age_group) ag ON c.current_age = ag.age
GROUP BY
	TRIM( year ) 
ORDER BY
	TRIM( year )