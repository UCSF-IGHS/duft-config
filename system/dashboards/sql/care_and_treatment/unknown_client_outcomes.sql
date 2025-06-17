SELECT COUNT(DISTINCT  fse.client_id) as value 
FROM mamba_fact_sentinel_event fse 
INNER JOIN mamba_dim_client dc ON dc.client_id = fse.client_id 
LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age  
WHERE retention IS NULL 