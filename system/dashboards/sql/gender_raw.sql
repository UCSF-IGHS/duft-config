SELECT DISTINCT UPPER(SUBSTR(gender, 1, 1)) || LOWER(SUBSTR(gender, 2)) as label, gender as value 
FROM dim_client