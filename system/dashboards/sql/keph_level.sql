SELECT DISTINCT 
    UPPER(SUBSTR(keph_level, 1, 1)) || LOWER(SUBSTR(keph_level, 2)) AS label,
    keph_level AS value
FROM dim_hiv_diagnosis_facility;