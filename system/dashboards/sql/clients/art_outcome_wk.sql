SELECT CASE WHEN ds.current_cascade_status='' THEN 'Case Closed' ELSE ds.current_cascade_status END AS category,COALESCE(COUNT(fd.client_id),0) AS value FROM (SELECT DISTINCT COALESCE(current_cascade_status,'') AS current_cascade_status FROM fact_sentinel_event) ds LEFT JOIN (SELECT se.client_id,COALESCE(se.current_cascade_status,'') AS current_cascade_status,strftime('%Y', se.hiv_diagnosis_date) AS year, gender, age_group FROM fact_sentinel_event se INNER JOIN dim_client c ON se.client_id=c.client_id INNER JOIN (SELECT age,TRIM(ten_year_interval) AS age_group FROM dim_age_group) a ON c.current_age=a.age) fd ON ds.current_cascade_status=fd.current_cascade_status GROUP BY ds.current_cascade_status;