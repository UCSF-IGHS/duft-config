SELECT fse.client_id,gender, hiv_diagnosis_date,enrolment_date,first_art_date, first_art_drugs,last_encounter_date,last_appointment_date,tx_curr
FROM mamba_fact_sentinel_event fse 
INNER JOIN mamba_dim_client dc on dc.client_id = fse.client_id 
LEFT JOIN mamba_dim_agegroup ag ON ag.age = dc.current_age
 WHERE first_art_date IS NOT NULL 