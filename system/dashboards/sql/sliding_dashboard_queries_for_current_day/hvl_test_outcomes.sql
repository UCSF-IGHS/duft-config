SELECT (CASE WHEN metric_name = 'total_hvl_target_not_detected' THEN 'TND' 
		 WHEN metric_name = 'total_suppressed_lt50' THEN '< 50' 
		 WHEN metric_name = 'total_suppressed_lt1000' THEN '>= 50 & < 1000'
		 WHEN metric_name = 'total_unsuppressed' THEN '>= 1000'
		 ELSE 'FAILED' END) as category, 
	sum(metric_value) as value
FROM todays_lab_analysis 
WHERE metric_type='HIVVL'
	AND metric_name IN ('total_hvl_target_not_detected', 'total_suppressed_lt50',
		'total_suppressed_lt1000', 'total_unsuppressed', 'hvl_failed')
GROUP BY metric_name
ORDER BY CASE WHEN metric_name = 'total_hvl_target_not_detected' THEN 1 
		 WHEN metric_name = 'total_suppressed_lt50' THEN 2 
		 WHEN metric_name = 'total_suppressed_lt1000' THEN 3 
		 WHEN metric_name = 'total_unsuppressed' THEN 4 
		 WHEN metric_name = 'hvl_failed' THEN 5 END