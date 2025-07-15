SELECT TOP 1
    MAX(previous_week_dates) AS date_range,
    MAX(f.hfr_code) AS hfr_code
FROM
    duft.dim_reporting_week
CROSS JOIN
    derived.dim_facility f