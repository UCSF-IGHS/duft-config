SELECT 
    last_encounter_is_receiving_differentiated_care AS category, 
    COUNT(DISTINCT fse.client_id) AS value 
FROM mamba_fact_sentinel_event fse 
INNER JOIN mamba_dim_client dc ON dc.client_id = fse.client_id 
LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age 
WHERE retention = 'Missed Appointment' 
AND (Gender = '$gender' OR '$gender' = '')  
AND (datim_agegroup='$agegroup' OR '$agegroup'='')
GROUP BY last_encounter_is_receiving_differentiated_care;