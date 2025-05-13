SELECT DISTINCT 
    UPPER(SUBSTR(keph_level, 1, 1)) || LOWER(SUBSTR(keph_level, 2)) AS label,
    keph_level AS value
FROM dim_hiv_diagnosis_facility f 
inner join fact_sentinel_event se on se.hiv_diagnosis_facility_id = f.facility_id;