SELECT category, sum(value) as value FROM vw_art_cascade GROUP BY category ORDER BY CASE WHEN category = 'New Cases' THEN 1 WHEN category = 'Initiated on ART' THEN 2 WHEN category = 'Suppressed' THEN 3 WHEN category = 'Not Suppressed' THEN 4 END