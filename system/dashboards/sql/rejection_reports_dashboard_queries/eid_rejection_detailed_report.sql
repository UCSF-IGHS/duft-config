SELECT 
		sample_tracking_id, [_hfr_id] ,df.facility_name, df.region, df.council,
		fst.collected_date, fst.lab_received_date, fst.rejection_reason 
FROM [derived].fact_sample_testing fst 
INNER JOIN [derived].dim_facility df on df.facility_id = fst.facility_id
WHERE is_sample_rejected = 1
    AND is_eid_sample = 1
    AND lab_received_date >= $[start_date%d]
    AND lab_received_date <= $[end_date%d]