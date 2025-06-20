SELECT TOP 1
    CASE WHEN MIN([Next Appointment Date]) IS NOT NULL THEN CONCAT(MIN([Next Appointment Date]), ' to ',
    MAX([Next Appointment Date])) END AS date_range
FROM
    duft.fact_duft_sentinel_event