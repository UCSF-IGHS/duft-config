
SELECT DISTINCT 
  UPPER(SUBSTR(facility_type, 1, 1)) || LOWER(SUBSTR(facility_type, 2)) AS label,
  facility_type AS value
FROM dim_hiv_diagnosis_facility f 
inner join fact_sentinel_event se on se.hiv_diagnosis_facility_id = f.facility_id
