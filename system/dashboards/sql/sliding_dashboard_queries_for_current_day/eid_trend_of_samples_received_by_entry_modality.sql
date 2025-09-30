SELECT 
	(CASE
		 WHEN metric_name = 'ENTRY FROM LAB' THEN 'LAB' 
		 WHEN metric_name = 'ENTRY FROM HUB' THEN 'HUB' 
		 WHEN metric_name = 'ENTRY FROM CTC' THEN 'CTC' END) as category, 
	sum(metric_value) as value 
FROM todays_lab_analysis 
WHERE metric_type='EID' 
      AND metric_name IN ('ENTRY FROM LAB', 'ENTRY FROM HUB', 'ENTRY FROM CTC')
GROUP BY metric_name
ORDER BY CASE
		 WHEN metric_name = 'ENTRY FROM LAB' THEN 1 
		 WHEN metric_name = 'ENTRY FROM HUB' THEN 2 
		 WHEN metric_name = 'ENTRY FROM CTC' THEN 3 END