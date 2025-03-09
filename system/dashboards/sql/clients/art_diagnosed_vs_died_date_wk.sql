
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
		inner join dim_hiv_diagnosis_date d on s.exit_date=d.full_date
		INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
GROUP BY gender, ten_year_interval, year

UNION

SELECT
    -COUNT(CASE WHEN exit_reason = 'Died' THEN 1 END) AS value,
    gender, 
    TRIM(ten_year_interval) AS age_group, 
    strftime('%Y', hiv_diagnosis_date) AS year
FROM
    fact_sentinel_event s
    INNER JOIN dim_client c ON c.client_id = s.client_id
    INNER JOIN dim_age_group ag ON c.current_age = ag.age
    INNER JOIN dim_exit_date e ON s.exit_date = e.full_date
    INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
GROUP BY 
    gender, 
    ten_year_interval, 
    year
) a
group by year
order by CAST(year AS integer)