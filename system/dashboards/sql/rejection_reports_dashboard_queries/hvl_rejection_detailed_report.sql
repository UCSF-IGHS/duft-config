SELECT 
		sample_tracking_id as sample_tracking_number, [_hfr_id] as hfr_code, df.facility_name,
        df.region, df.council, fst.collected_date, fst.lab_received_date AS received_date,
        fst.rejection_reason 
FROM [derived].fact_sample_testing fst 
INNER JOIN [derived].dim_facility as df on df.facility_id = fst.facility_id
WHERE is_sample_rejected = 1
    AND is_hvl_sample = 1
    AND lab_received_date >= $[start_date%d]
    AND lab_received_date <= $[end_date%d] 
    AND is_valid_record = 1