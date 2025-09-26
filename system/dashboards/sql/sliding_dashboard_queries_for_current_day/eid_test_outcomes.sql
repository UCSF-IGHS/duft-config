SELECT (CASE WHEN metric_name = 'total_eid_negative' THEN 'negative' 
		 WHEN metric_name = 'total_eid_positive' THEN 'positive' 
		 WHEN metric_name = 'total_eid_indeterminate' THEN 'indeterminate' END) as category, 
	sum(metric_value) as value
FROM todays_lab_analysis 
WHERE metric_type='EID'
	AND metric_name in ('total_eid_negative', 'total_eid_positive', 'total_eid_indeterminate')
GROUP BY metric_name
ORDER BY CASE WHEN metric_name = 'total_eid_negative' THEN 1 
		 WHEN metric_name = 'total_eid_positive' THEN 2 
		 WHEN metric_name = 'total_eid_indeterminate' THEN 3 END