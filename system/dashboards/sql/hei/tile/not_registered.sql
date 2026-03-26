SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event se
INNER JOIN
    derived.dim_date dd
    ON se.[Pregnancy Due Date] = dd.[date]
INNER JOIN
    duft.dim_reporting_week drwdd
    ON dd.weekly_start_monday_end_date = drwdd.previous_week_end_date
WHERE NOT EXISTS
(
    SELECT
        *
    FROM
        duft.fact_duft_hei_sentinel_event hse
    INNER JOIN
        derived.dim_date dd
        ON hse.[Due Date] = dd.[date]
    INNER JOIN
        duft.dim_reporting_week drwdd
        ON dd.weekly_start_monday_end_date = drwdd.previous_week_end_date
    WHERE
        hse.[Patient Id] = se.[Patient ID]
)