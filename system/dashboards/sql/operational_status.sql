SELECT DISTINCT 
    UPPER(SUBSTR(operational_status, 1, 1)) || LOWER(SUBSTR(operational_status, 2)) AS label,
    operational_status AS value
FROM dim_hiv_diagnosis_facility;