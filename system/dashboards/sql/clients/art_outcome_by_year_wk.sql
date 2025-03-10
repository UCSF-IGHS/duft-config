SELECT 
    v.year AS category,
    SUM(CASE WHEN v.category = 'New Cases' THEN v.value ELSE 0 END) AS "New Cases",
    SUM(CASE WHEN v.category = 'Initiated on ART' THEN v.value ELSE 0 END) AS "Initiated on ART",
    SUM(CASE WHEN v.category = 'Suppressed' THEN v.value ELSE 0 END) AS "Suppressed",
    SUM(CASE WHEN v.category = 'Not Suppressed' THEN v.value ELSE 0 END) AS "Not Suppressed"
FROM vw_art_cascade v
JOIN (SELECT strftime('%Y', date('now', '-14 years')) AS cutoff_year) c
ON v.year >= c.cutoff_year
GROUP BY v.year
ORDER BY v.year