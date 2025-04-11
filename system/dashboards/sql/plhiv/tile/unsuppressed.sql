SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
   ( 
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last VL Is Unsuppressed] = 'Yes'
   )
OR
    [Last VL Result in Previous Week] = 'Yes'
AND
    [Last Date Initiated EAC] IS NULL