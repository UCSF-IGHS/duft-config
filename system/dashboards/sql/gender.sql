SELECT
  CASE
    WHEN ROW_NUMBER() OVER () = 1 THEN 'XX'
    ELSE 'XY'
  END AS label,
  gender AS value
FROM
  (
    SELECT DISTINCT
      gender
    FROM
      dim_client
  ) AS distinct_genders;