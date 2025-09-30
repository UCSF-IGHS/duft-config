SELECT 
	metric_name as category, 
	sum(metric_value) as value 
FROM todays_lab_analysis 
WHERE metric_type='HIVVL' 
      and metric_name in ('received', 'rejected', 'tested', 'authorised')
GROUP BY metric_name
ORDER BY CASE WHEN metric_name = 'received' THEN 1 
		 WHEN metric_name = 'rejected' THEN 2 
		 WHEN metric_name = 'tested' THEN 3 
		 WHEN metric_name = 'authorised' THEN 4 END