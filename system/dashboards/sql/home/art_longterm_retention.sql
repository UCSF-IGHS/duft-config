
SELECT
	SUM( CASE WHEN num = 'Active Clients' THEN value ELSE 0 END ) AS 'Active Clients',
	SUM( CASE WHEN num = 'Years on ART' THEN value ELSE 0 END ) AS category
FROM
	(
	SELECT
		year,
		'Active Clients' AS num,
		COUNT( first_art_date ) AS value ,
		gender, 
		TRIM(ten_year_interval) AS age_group
	FROM
		fact_sentinel_event se
		INNER JOIN dim_client c ON se.client_id = c.client_id
		INNER JOIN dim_first_art_date d ON se.first_art_date = d.full_date 
		INNER JOIN dim_age_group ag ON c.current_age = ag.age 
	WHERE
		year BETWEEN 2005 
		AND 2023 
		AND is_currently_on_art = 1 
	GROUP BY
		year UNION ALL
	SELECT
		year,
		'Years on ART' AS num,
		CAST (
			(
				strftime( '%Y', 'now' ) - CAST (
					SUBSTR( first_art_date, LENGTH( first_art_date ) - 3 ) AS INTEGER 
				) 
			) AS INTEGER 
		) AS value ,
		gender, 
		TRIM(ten_year_interval) AS age_group
	FROM
		fact_sentinel_event se
		INNER JOIN dim_client c ON se.client_id = c.client_id
		INNER JOIN dim_first_art_date d ON se.first_art_date = d.full_date 
		INNER JOIN dim_age_group ag ON c.current_age = ag.age 
	WHERE
		is_currently_on_art = 1 
	GROUP BY
		year 
	) AS combined 
WHERE 
    year > 2005 AND (gender = '$gender' OR '$gender' = '') 
    AND ( age_group = '$age_group' OR '$age_group' = '')
GROUP BY year
ORDER BY
	category DESC
