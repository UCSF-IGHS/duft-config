SELECT year AS category, COUNT(first_art_date) AS value FROM fact_sentinel_event se INNER JOIN dim_client c ON se.client_id=c.client_id INNER JOIN (SELECT age, TRIM(ten_year_interval) as age_group FROM dim_age_group) ag ON c.current_age = ag.age INNER JOIN dim_first_art_date d ON se.first_art_date=d.full_date WHERE is_currently_on_art=1 AND year BETWEEN 2000 and 2007 GROUP BY year