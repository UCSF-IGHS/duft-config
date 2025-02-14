WITH first_visit_after_delivery AS (
    SELECT
        fv.client_id,
        fv.visit_date,
        ROW_NUMBER() OVER (PARTITION BY fv.client_id ORDER BY fv.visit_date ASC) AS rn
    FROM
        derived.fact_visit fv
    INNER JOIN
        base.fact_pregnancy fp
        ON fv.client_id = fp.ctc_client_id
    WHERE fv.visit_date > fp.delivery_date
)

SELECT
    dc.ctc_id AS [CTC ID],
    dc.client_id AS [Client ID],
    expected_delivery_date AS [Due Date],
    delivery_date AS [Delivery Date],
    gender AS [Sex],
    pregnancy_outcome AS [Pregnancy Outcome],
    date_of_birth AS [DOB],
    CASE
        WHEN date_of_death IS NULL
            THEN dbo.fn_staging_calculate_age(date_of_birth, GETDATE())
        ELSE dbo.fn_staging_calculate_age(date_of_birth, date_of_death)
    END AS [Current Age],
    fv.visit_date AS [Registration Date],
    date_of_death AS [Date of Death]
FROM
    base.fact_pregnancy fp
INNER JOIN
    derived.dim_client dc
    ON fp.ctc_client_id = dc.client_id
LEFT JOIN
    first_visit_after_delivery fv
    ON fp.ctc_client_id = fv.client_id
    AND fv.rn = 1
WHERE
    fp.delivery_date IS NOT NULL
    AND fv.visit_date IS NULL
ORDER BY
    ctc_client_id