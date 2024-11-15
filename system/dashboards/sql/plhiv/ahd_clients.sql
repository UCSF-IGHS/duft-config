WITH limits AS (
    SELECT
        client_id,
        result.report_date AS cd4_result_date,
        result.cd4_count_result AS cd4_count_result,
        d.weekly_start_monday_end_date AS cd4_week_end_date
    FROM
        derived.fact_ctc_daily_client_status AS result
    INNER JOIN
        derived.dim_date d ON d.date = result.report_date
    AND
        result.has_cd4_less_than_200 = 1
)

SELECT
    f.report_date AS [Report Date],
    f.ctc_id AS [CTC ID],
    f.current_age AS Age,
    f._date_of_birth AS DOB,
    f.gender AS Sex,
    l.cd4_result_date AS [CD4 Test Date],
    l.cd4_count_result AS [CD4 Result],
    f.had_cd4_less_than_200 AS [CD4 < 200],
    f.has_no_cd4_tst_who_stage_3_4_exclusively_weekly AS [WHO Stage 3/4],
    'Y' AS [AHD Suspect]
FROM
    derived.fact_ctc_daily_client_status f
INNER JOIN
    derived.dim_date d ON d.[date] = f.report_date
AND
    d.weekly_start_monday_end_date = COALESCE(NULLIF('$week', ''), '2024-06-02')
LEFT JOIN
    limits l ON l.client_id = f.client_id
WHERE
    (
        f.report_date = d.weekly_start_monday_end_date
        AND f.has_no_cd4_tst_who_stage_3_4_exclusively_weekly = 1
    )
    OR
    (
        f.has_cd4_less_than_200 = 1
        AND f.report_date BETWEEN l.cd4_result_date AND l.cd4_week_end_date
    )
ORDER BY
    f.report_date ASC