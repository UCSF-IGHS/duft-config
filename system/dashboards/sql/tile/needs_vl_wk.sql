SELECT 
    SUM(initiated_on_art) - (SUM(suppressed) + SUM(not_suppressed)) AS needs_viral_load_test, 
    PRINTF('%.1f%%', 
        (SUM(initiated_on_art) - (SUM(suppressed) + SUM(not_suppressed))) * 100.0 / SUM(initiated_on_art)
    ) AS percentage_need_vl_test
FROM vw_art_cascade_for_tiles