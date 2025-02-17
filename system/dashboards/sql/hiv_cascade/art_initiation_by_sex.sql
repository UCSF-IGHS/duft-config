SELECT c.gender as category, COUNT(c.client_id) as value 
FROM mamba_fact_sentinel_event e 
INNER JOIN mamba_dim_client c ON e.client_id=c.client_id 
LEFT JOIN mamba_dim_agegroup ag ON ag.age = c.current_age 
WHERE e.first_art_date IS NOT NULL AND  (Gender ='$gender' OR '$gender'='') 
AND (datim_agegroup='$agegroup' OR '$agegroup'='')
GROUP BY c.gender