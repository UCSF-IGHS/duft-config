
SELECT DISTINCT 
  UPPER(SUBSTR(facility_type, 1, 1)) || LOWER(SUBSTR(facility_type, 2)) AS label,
  facility_type AS value
FROM dim_hiv_diagnosis_facility;
