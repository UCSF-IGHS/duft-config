SELECT 
    COUNT(*) 
FROM 
    duft.fact_duft_hei_sentinel_event 
WHERE
    (
        [Last Appointment in Previous Week] = 'Yes'
AND     [Has Final Outcome] = 'No'
AND     [HEI Current Age in Months] BETWEEN 18 AND 24
    )
AND 
        ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')