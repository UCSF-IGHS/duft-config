-- SELECT  hts_tst, hts_tst_neg, hts_tst_pos FROM final.fact_ctc_daily_facility_summary 

-- SELECT hts_date_of_birth, hts_age_at_test, hts_sex_code, f.hts_client_code, hiv_test_date, hiv_testing_point, hts_attendance_type, hts_referred_from, hts_ctc_id, * FROM derived.fact_hiv_testing f INNER JOIN derived.dim_hts_client c ON f.hts_client_id = c.hts_client_id WHERE is_valid_hiv_test = 1

-- WHERE hts_ctc_id IS NOT NULL


-- SELECT SUM(is_hiv_negative) AS total_hiv_negative, (SUM(is_hiv_negative) * 1.0 / NULLIF(SUM(is_valid_hiv_test), 0) * 100) AS percentage_hiv_negative FROM derived.fact_hiv_testing f;

-- SELECT SUM(is_hiv_negative), ((SUM(is_hiv_negative) / SUM(is_valid_hiv_test)) * 100) FROM derived.fact_hiv_testing f;

SELECT SUM(is_hiv_negative) AS total_hiv_negative, CAST(CAST((SUM(is_hiv_negative) * 1.0 / NULLIF(SUM(is_valid_hiv_test), 0) * 100) AS DECIMAL(10, 1)) AS VARCHAR(10)) + '%' AS percentage_hiv_negative FROM derived.fact_hiv_testing f;

SELECT SUM(is_hiv_negative), CAST(SUM(is_hiv_negative) AS FLOAT) / SUM(is_valid_hiv_test) * 100 FROM derived.fact_hiv_testing f;

