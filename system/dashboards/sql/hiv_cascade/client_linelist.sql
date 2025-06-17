SELECT 
DISTINCT dc.Client_id, Gender, birth_date "DOB", 
current_age 'Age',dc.marital_status,first_art_date "ART Start Date",
last_encounter_is_receiving_differentiated_care as 'DSD', 
Retention,last_encounter_date "Last Follow Up Date",
last_appointment_date "Next Visit Date" 
FROM mamba_fact_sentinel_event fse 
INNER JOIN mamba_dim_client dc on dc.client_id = fse.client_id
 LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age 
 WHERE first_art_date IS NOT NULL 
 