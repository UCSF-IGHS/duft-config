-- SELECT report_date AS [Report Date], f.gender AS Sex, current_age AS Age, v.viral_load_test_date AS [VL Test Date], viral_load_test_result_numeric AS [VL Result], v.viral_load_test_result_text AS [Result Text], v.next_viral_load_test_date AS [Next VL Date], clients_eligible_for_viral_load_testing_with_sample_not_taken AS [Eligible for VL], has_visited AS [Attended] FROM derived.fact_ctc_daily_client_status f INNER JOIN derived.dim_client c ON f.client_id = c.client_id INNER JOIN derived.dim_date d ON f.report_date = d.[date] INNER JOIN derived.fact_viral_load_test v ON f.client_id = v.client_id AND v.viral_load_test_date = ( SELECT MAX(viral_load_test_date) FROM derived.fact_viral_load_test v WHERE v.viral_load_test_date <= f.report_date AND v.client_id = f.client_id ) AND clients_eligible_for_viral_load_testing = 1 AND d.weekly_start_monday_end_date = COALESCE(NULLIF('$week', ''), '2024-06-02') ORDER BY f.report_date

BEGIN


DECLARE @week DATE;
SET @week = CONVERT(DATE, '2024-07-21');


SELECT f.hts_client_code AS [HTS Client Code], hts_age_at_test AS Age, hts_sex_code AS Sex, hiv_test_date AS [Test Date], hiv_testing_point AS [Testing Point], hts_attendance_type AS [Attendance Type], hts_ctc_id AS [CTC ID] FROM derived.fact_hiv_testing f INNER JOIN derived.dim_hts_client c ON f.hts_client_id = c.hts_client_id INNER JOIN derived.dim_date d ON f.hiv_test_date = d.[date] WHERE is_valid_hiv_test = 1 AND d.weekly_start_monday_end_date = COALESCE(NULLIF(@week, ''), '2024-06-02');

END