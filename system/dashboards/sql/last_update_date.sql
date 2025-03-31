select
  strftime ('%Y-%m-%d', last_refresh_date) as last_refresh_date,
  'Wakanda Hospital' as facility_name
FROM
  last_refresh_date