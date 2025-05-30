SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [AHD Suspect Within 30 Days] = 'Yes'
        -- AND [Last Appointment in Previous Week] = 'Yes'
    )
    OR
    (
        [Last CD4 < 200] = 'Yes'
        -- AND [Last CD4 Result in Previous Week] = 'Yes'
    )