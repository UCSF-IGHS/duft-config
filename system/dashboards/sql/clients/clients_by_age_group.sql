
select COUNT(*) as value, TRIM(ten_year_interval) as category
from fact_sentinel_event se 
inner join dim_age_group ag on se.hiv_diagnosis_age_group_id=ag.age_group_id
GROUP BY category
