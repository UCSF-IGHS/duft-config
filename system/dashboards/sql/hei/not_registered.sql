WITH first_visit AS (
    SELECT
        client_id,
        visit_date,
        ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY visit_date ASC) AS rn
    FROM derived.fact_visit
)

SELECT
    dc.client_id AS [Client ID],
    expected_delivery_date AS [Due Date],
    expected_delivery_date AS [EDD],
    delivery_date AS [Delivery Date],
    gender AS [Sex],
    pregnancy_outcome AS [Pregnancy Outcome],
    date_of_birth AS [DOB],
    CASE
        WHEN date_of_death IS NULL
            THEN dbo.fn_staging_calculate_age(date_of_birth, GETDATE())
    END AS [Current Age],
    visit_date AS [Registration Date],
    date_of_death AS [Date of Death]
FROM base.fact_pregnancy fp
INNER JOIN
    derived.dim_client dc
    ON fp.ctc_client_id = dc.client_id
INNER JOIN
    first_visit fv
    ON fp.ctc_client_id = fv.client_id
    AND fv.rn = 1
ORDER BY
    dc.client_id