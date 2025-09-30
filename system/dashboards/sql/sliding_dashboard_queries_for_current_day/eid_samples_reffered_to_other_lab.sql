SELECT 
	metric_name as category, 
	sum(metric_value) as value 
FROM todays_lab_analysis 
WHERE metric_type='EID' 
      AND metric_name IN ('Reffered', 'Rejected At Other Lab', 'Results At Other Lab')
GROUP BY metric_name
ORDER BY CASE WHEN metric_name = 'Reffered' THEN 1 
			 WHEN metric_name = 'Rejected At Other Lab' THEN 2 
			 WHEN metric_name = 'Results At Other Lab' THEN 3 END