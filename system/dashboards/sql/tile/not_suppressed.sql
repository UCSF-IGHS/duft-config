SELECT SUM(not_suppressed) AS not_suppressed, PRINTF ('%.1f%%',SUM(not_suppressed) * 100.0 /SUM(initiated_on_art)) AS percentage_not_suppressed FROM vw_art_cascade_for_tiles WHERE (gender = '$gender' OR '$gender' = '') AND (age_group = '$age_group' OR '$age_group' = '');