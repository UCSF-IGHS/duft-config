SELECT COUNT(*) as value FROM (select strftime('%Y',  hiv_diagnosis_date) AS year, client_id, hiv_diagnosis_date, enrolment_date, has_ever_been_initiated_on_art from fact_sentinel_event) fs INNER JOIN dim_client dc ON dc.client_id = fs.client_id INNER JOIN ( SELECT age, TRIM(ten_year_interval) as age_group FROM dim_age_group) ag ON dc.current_age = ag.age WHERE enrolment_date !='' 