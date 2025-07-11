SELECT TOP 1
    CASE WHEN MIN([Next Appointment Date]) IS NOT NULL THEN CONCAT(MIN([Next Appointment Date]), ' to ',
    MAX([Next Appointment Date])) END AS date_range,
    MAX(f.hfr_code) AS hfr_code
FROM
    duft.fact_duft_sentinel_event
CROSS JOIN
    derived.dim_facility f