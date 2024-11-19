WITH last_visit AS (
    SELECT
        v.client_id,
        v.visit_date,
        p.prescription_date,
        p.number_of_days_prescribed,
        ROW_NUMBER() OVER (PARTITION BY v.client_id ORDER BY v.visit_date DESC) AS rn
    FROM
        derived.fact_visit v
    INNER JOIN
        derived.fact_art_prescription p
    ON
        v.client_id = p.client_id
    AND
        v.visit_date = p.prescription_date
)

SELECT
    f.report_date AS [Report Date],
    f.ctc_id AS [CTC ID],
    f.current_age AS Age,
    f._date_of_birth AS DOB,
    f.gender AS Sex,
    lv.visit_date AS [Last Visit Date],
    DATEDIFF(DAY, lv.visit_date, f.report_date) AS [Days Since Last Visit],
    lv.number_of_days_prescribed AS [Number of Days Prescribed],
    f.has_drugs AS [Has Drugs],
    f.days_missed_drugs AS [Days Missed Drugs]
FROM
    derived.fact_ctc_daily_client_status f
INNER JOIN
    derived.dim_client c ON f.client_id = c.client_id
INNER JOIN
    derived.dim_date d ON f.report_date = d.[date]
INNER JOIN
    last_visit lv ON f.client_id = lv.client_id
WHERE
    lv.rn = 1
AND
    lv.visit_date < f.report_date
AND
    f.has_missed_drugs_for_more_than_28_days_up_to_end_of_reporting_period = 1
AND
    d.weekly_start_monday_end_date = COALESCE(NULLIF('$week', ''), '2024-06-02')
ORDER BY
    f.report_date ASC