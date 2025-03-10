select year as category,  SUM(CASE WHEN se.has_ever_been_initiated_on_art != 0 THEN 1 ELSE 0 END) AS 'Initiated', SUM(CASE WHEN se.has_never_been_initiated_on_art = 1 THEN 1 ELSE 0 END) AS 'Not Initiated'
FROM fact_sentinel_event se
INNER JOIN dim_client c ON se.client_id = c.client_id
INNER JOIN (select age, TRIM(ten_year_interval) as age_group from dim_age_group) a ON c.current_age = a.age 
INNER JOIN (SELECT d.*
FROM dim_date d
JOIN (SELECT DATE('now', '-14 years') AS min_date) AS filter_dates
ON DATE(d.full_date) >= filter_dates.min_date) d ON se.hiv_diagnosis_date = d.full_date
GROUP BY year