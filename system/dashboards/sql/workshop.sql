-- SELECT  hts_tst, hts_tst_neg, hts_tst_pos FROM final.fact_ctc_daily_facility_summary 

SELECT hts_date_of_birth, hts_age_at_test, hts_sex_code, f.hts_client_code, hiv_test_date, hiv_testing_point, hts_attendance_type, hts_referred_from, hts_ctc_id, * FROM derived.fact_hiv_testing f INNER JOIN derived.dim_hts_client c ON f.hts_client_id = c.hts_client_id WHERE is_valid_hiv_test = 1

-- WHERE hts_ctc_id IS NOT NULL


SELECT COUNT(*) count_, is_valid_hiv_test, is_hiv_negative, is_hiv_positive FROM derived.fact_hiv_testing GROUP BY is_valid_hiv_test, is_hiv_negative, is_hiv_positive