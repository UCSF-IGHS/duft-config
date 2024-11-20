WITH last_prescription AS (
    SELECT
        p.prescription_date,
        p.client_id,
        p.number_of_days_prescribed,
        ROW_NUMBER() OVER (PARTITION BY p.client_id ORDER BY p.prescription_date DESC) AS rn
    FROM
        derived.fact_art_prescription p
),
client_status AS (
    SELECT DISTINCT
        f.client_id,
        lp.number_of_days_prescribed,
        d.weekly_start_monday_end_date,
        has_missed_drugs_for_more_than_28_days_up_to_end_of_reporting_period AS iit_28_90,
        lp.prescription_date,
        f.days_missed_drugs,
        lp.rn
    FROM
        derived.fact_ctc_daily_client_status f
    LEFT JOIN
        last_prescription lp ON f.client_id = lp.client_id
    AND
        lp.rn = 1
    AND
        lp.prescription_date <= f.report_date
    INNER JOIN
        derived.dim_date d ON f.report_date = d.[date]
    WHERE
        f.has_missed_drugs_for_more_than_28_days_up_to_end_of_reporting_period = 1
    AND
        d.weekly_start_monday_end_date = COALESCE(NULLIF('$week', ''), '2024-06-23')
),
total_count_cte AS (
    SELECT COUNT(*) AS total_count FROM client_status
)

SELECT
    categories.mmd_status AS category,
    COUNT(
        CASE
            WHEN categories.mmd_status = '1 month' AND cs.number_of_days_prescribed < 75 THEN 1
            WHEN categories.mmd_status = '3 months' AND cs.number_of_days_prescribed BETWEEN 75 AND 149 THEN 1
            WHEN categories.mmd_status = '6 months' AND cs.number_of_days_prescribed > 149 THEN 1
            WHEN categories.mmd_status = 'Unknown' AND ISNULL(cs.number_of_days_prescribed, 0) = 0 THEN 1
        END
    ) AS value,
    CASE
        WHEN total.total_count = 0 THEN '0%'
        ELSE CONCAT(
            ROUND(
                (COUNT(
                    CASE
                        WHEN categories.mmd_status = '1 month' AND cs.number_of_days_prescribed < 75 THEN 1
                        WHEN categories.mmd_status = '3 months' AND cs.number_of_days_prescribed BETWEEN 75 AND 149 THEN 1
                        WHEN categories.mmd_status = '6 months' AND cs.number_of_days_prescribed > 149 THEN 1
                        WHEN categories.mmd_status = 'Unknown' AND ISNULL(cs.number_of_days_prescribed, 0) = 0 THEN 1
                    END
                ) * 100.0 /total.total_count),
                1
            ),
            '%'
        )
    END AS percentage
FROM
    (SELECT '1 month' AS mmd_status
     UNION ALL
     SELECT '3 months'
     UNION ALL
     SELECT '6 months'
     UNION ALL
     SELECT 'Unknown') AS categories
LEFT JOIN
    client_status cs
ON
    (categories.mmd_status = '1 month' AND cs.number_of_days_prescribed < 75)
    OR (categories.mmd_status = '3 months' AND cs.number_of_days_prescribed BETWEEN 75 AND 149)
    OR (categories.mmd_status = '6 months' AND cs.number_of_days_prescribed > 149)
    OR (categories.mmd_status = 'Unknown' AND cs.number_of_days_prescribed IS NULL)
CROSS JOIN
    total_count_cte total
WHERE
    client_id IS NOT NULL
GROUP BY
    categories.mmd_status, total.total_count
ORDER BY
    CASE
        WHEN categories.mmd_status = '1 month' THEN 1
        WHEN categories.mmd_status = '3 months' THEN 2
        WHEN categories.mmd_status = '6 months' THEN 3
        WHEN categories.mmd_status = 'Unknown' THEN 4
    END
