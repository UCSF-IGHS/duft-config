SELECT 
    COUNT(*) 
FROM 
    duft.fact_duft_hei_sentinel_event 
WHERE 
    [HEI Registered] = 'No' 
AND 
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')