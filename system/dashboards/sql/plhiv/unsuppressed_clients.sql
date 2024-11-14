WITH last_vl AS (
    SELECT
        client_id,
        viral_load_test_date,
        viral_load_result_date,
        viral_load_test_result_numeric,
        ISNULL(is_viral_load_suppressed_50, 0) AS is_viral_load_suppressed_50,
        viral_load_result_less_than_1000_copies,
        ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY viral_load_result_date DESC) AS rn
    FROM
        derived.fact_viral_load_test
),
next_eac AS (
    SELECT
        client_id,
        date_initiated_eac,
        date_completed_eac,
        date_hvl_test_after_eac,
        ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY date_initiated_eac ASC) AS rn
    FROM
        derived.fact_eac
)

SELECT
    f.report_date AS [Report Date],
    f.ctc_id AS [CTC ID],
    f.current_age AS Age,
    f._date_of_birth AS DOB,
    f.gender AS Sex,
    lv.viral_load_test_date AS [Last VL Test Date],
    lv.viral_load_result_date AS [Last VL Result Date],
    lv.viral_load_test_result_numeric AS [Last VL Result],
    CASE WHEN lv.viral_load_result_date IS NOT NULL AND lv.is_viral_load_suppressed_50 = 0 THEN 'N' END AS [Last VL Suppressed?],
    ne.date_initiated_eac AS [Date Initiated EAC]
FROM
    derived.fact_ctc_daily_client_status f
INNER JOIN
    last_vl lv ON f.client_id = lv.client_id
LEFT JOIN
    next_eac ne ON f.client_id = ne.client_id
AND
    ne.rn = 1
AND
    lv.viral_load_result_date < ne.date_initiated_eac
INNER JOIN
    derived.dim_date d ON d.[date] = lv.viral_load_test_date
WHERE
    lv.is_viral_load_suppressed_50 = 0
AND
    lv.rn = 1
AND
    lv.viral_load_test_date < f.report_date
AND
    d.weekly_start_monday_end_date = COALESCE(NULLIF('$week', ''), '2024-06-09')
ORDER BY
    f.report_date ASC