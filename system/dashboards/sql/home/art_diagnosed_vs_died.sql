select month_name AS category , sum(value)  as value
from 
(
SELECT
		COUNT(1) AS value,
	 month_name,
	 month_of_year,
	 'Diagnosed' || ' - ' || month_name AS category_month,
		gender, 
		TRIM(ten_year_interval) AS age_group, 
		SUBSTR(hiv_diagnosis_date, -4) AS year
FROM
		fact_sentinel_event s
		INNER JOIN dim_client c ON c.client_id = s.client_id
		INNER JOIN dim_age_group ag ON c.current_age = ag.age
		inner join dim_hiv_diagnosis_date d on s.exit_date=d.full_date
		INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
WHERE hiv_diagnosis_date IS NOT NULL 
GROUP BY gender, ten_year_interval, year, month_name, month_of_year

UNION

SELECT
		-COUNT(1) AS value,
	 month_name,
	 month_of_year,
	 'Died' || ' - ' || month_name AS category_month,
		gender, 
		TRIM(ten_year_interval) AS age_group, 
		SUBSTR(hiv_diagnosis_date, -4) AS year
FROM
		fact_sentinel_event s
		INNER JOIN dim_client c ON c.client_id = s.client_id
		INNER JOIN dim_age_group ag ON c.current_age = ag.age
		inner join dim_exit_date e on s.exit_date=e.full_date
		INNER JOIN dim_hiv_diagnosis_facility f ON f.facility_id = s.hiv_diagnosis_facility_id
WHERE exit_reason = 'Died'
GROUP BY gender, ten_year_interval, year, month_name, month_of_year


) a
where (gender = '$gender' OR '$gender' = '') AND (age_group = '$age_group' OR '$age_group' = '') AND (year = COALESCE(NULLIF('$year', ''), '2021'))
GROUP BY category_month
ORDER BY CAST(month_of_year AS integer)