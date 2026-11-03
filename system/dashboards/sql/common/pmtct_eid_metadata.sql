SELECT TOP 1
    CASE
        WHEN MIN([Week End Date]) = MAX([Week End Date]) THEN CAST(MIN([Week End Date]) AS VARCHAR)
        ELSE CONCAT(MIN([Week End Date]), ' to ', MAX([Week End Date]))
    END AS date_range,
    MAX(f.hfr_code) AS hfr_code
FROM
    duft.fact_duft_pmtct_eid_clients
CROSS JOIN
    derived.dim_facility f