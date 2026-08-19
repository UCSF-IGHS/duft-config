
SELECT
    f.ctc_id AS [Mother patient ID],

    f.exposed_infant_number AS [HEI_NO],

    di.exposed_infant_date_of_birth AS [Date of Birth],
    
    CAST((f.days_since_birth_date / 30) AS FLOAT) AS [Age (Months)],

    f.eid_visit_date AS [Last visit date],

    f.eid_test_date AS [Test Date],

    f.eid_test_result AS [Test Date results],

    CASE
        WHEN f.hei_registered = 1 THEN 'Y'
        ELSE 'N'
    END AS [HEI registered at birth],

    CASE
        WHEN f.has_4_to_6_weeks_of_age = 1 THEN 'Y'
        ELSE 'N'
    END AS [4 to 6 Weeks HEI Eligible for DNA PCR Test],

    CASE
        WHEN f.has_9_months_of_age = 1 THEN 'Y'
        ELSE 'N'
    END AS [9 Months HEI Eligible for DNA PCR Test],

    CASE
        WHEN f.has_3_months_post_cessation_of_bf = 1 THEN 'Y'
        ELSE 'N'
    END AS [3 Months Post BF HEI Eligible for DNA PCR Test],

    CASE
        WHEN f.has_18_months_of_age = 1 THEN 'Y'
        ELSE 'N'
    END AS [18 Months HEI Eligible for DNA PCR Test],

    CASE
        WHEN f.has_4_to_6_weeks_of_age_and_attended = 1
          OR f.has_9_months_of_age_and_attended = 1
          OR f.has_3_months_post_cessation_of_bf_and_attended = 1
          OR f.has_18_months_of_age_and_attended = 1
        THEN 'Y'
        ELSE 'N'
    END AS [HEI Eligible and attended],

    CASE
        WHEN f.has_4_to_6_weeks_of_age_attended_with_documented_dna_pcr = 1
          OR f.has_9_months_of_age_attended_with_documented_dna_pcr = 1
          OR f.has_3_months_post_cessation_of_bf_attended_with_documented_dna_pcr = 1
          OR f.has_18_months_of_age_attended_with_documented_dna_pcr = 1
        THEN 'Y'
        ELSE 'N'
    END AS [HEI Attended and Sample Taken],

    CASE
        WHEN f.has_4_to_6_weeks_of_age_with_no_documented_dna_pcr = 1
          OR f.has_9_months_of_age_with_no_documented_dna_pcr = 1
          OR f.has_3_months_post_cessation_of_bf_with_no_documented_dna_pcr = 1
          OR f.has_18_months_of_age_with_no_documented_dna_pcr = 1
        THEN 'Y'
        ELSE 'N'
    END AS [HEI with Undocumented DNA PCR Test]

FROM [ctca_etl_analytics].[derived].[fact_ctc_daily_client_status] f
LEFT JOIN [ctca_etl_analytics].[derived].[dim_exposed_infant] di
    ON f.exposed_infant_id = di.exposed_infant_id

WHERE f.exposed_infant_id IS NOT NULL
    AND f.eid_visit_date $[Last Appointment Date%r]
