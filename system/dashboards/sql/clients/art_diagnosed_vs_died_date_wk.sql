
select year AS category , sum(value)  as value
from 
(
SELECT
		COUNT(CASE WHEN hiv_diagnosis_date IS NOT NULL THEN 1 END) AS value,
		gender, 
		TRIM(ten_year_interval) AS age_group, 
		strftime('%Y', hiv_diagnosis_date) AS year
FROM
		fact_sentinel_event s
		INNER JOIN dim_client c ON c.client_id = s.client_id
		INNER JOIN dim_age_group ag ON c.current_age = ag.age
        INNER JOIN 
        (SELECT d.*
FROM dim_hiv_diagnosis_date d
JOIN (SELECT DATE('now', '-14 years') AS min_date) AS filter_dates
ON DATE(d.full_date) >= filter_dates.min_date) d ON s.hiv_diagnosis_date = d.full_date
		INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
GROUP BY gender, ten_year_interval, year

UNION

SELECT
    -COUNT(CASE WHEN exit_reason = 'Died' THEN 1 END) AS value,
    gender, 
    TRIM(ten_year_interval) AS age_group, 
    strftime('%Y', exit_date) AS year
FROM
    fact_sentinel_event s
    INNER JOIN dim_client c ON c.client_id = s.client_id
    INNER JOIN dim_age_group ag ON c.current_age = ag.age
    INNER JOIN (SELECT d.*
FROM dim_exit_date d
JOIN (SELECT DATE('now', '-14 years') AS min_date) AS filter_dates
ON DATE(d.full_date) >= filter_dates.min_date) d ON s.exit_date = d.full_date
    INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
GROUP BY 
    gender, 
    ten_year_interval, 
    year
) a
group by year
order by CAST(year AS integer)