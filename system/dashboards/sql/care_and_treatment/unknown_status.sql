SELECT 
    DISTINCT dc.client_id,gender, birth_date, first_art_date,
    last_seen_date,last_appointment_date as "Next Visit",
    last_encounter_is_receiving_differentiated_care as "MMP Status", 
    Retention FROM mamba_fact_sentinel_event fse 
INNER JOIN mamba_dim_client dc ON dc.client_id = fse.client_id 
LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age  
WHERE retention IS NULL 
AND  (Gender='$gender' OR '$gender'='') 
AND (datim_agegroup='$agegroup' OR '$agegroup'='')