SELECT COUNT(DISTINCT dc.client_id) AS value, datim_agegroup AS category
FROM mamba_fact_sentinel_event fse
INNER JOIN mamba_dim_client dc on dc.client_id = fse.client_id
LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age
WHERE first_art_date IS NOT NULL 
GROUP BY datim_agegroup;