SELECT COUNT(*) 
    FROM duft.fact_duft_hei_sentinel_event 
WHERE [Eligible for First EID Test] = 'Yes' AND ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')