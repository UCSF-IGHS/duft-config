select facility_name, facility_type, keph_level, operational_status, latitude, longitude, count(client_id) as ct
from  dim_hiv_diagnosis_facility f 
left join fact_sentinel_event se on se.hiv_diagnosis_facility_id = f.facility_id
group by facility_name, facility_type, keph_level, operational_status, latitude, longitude