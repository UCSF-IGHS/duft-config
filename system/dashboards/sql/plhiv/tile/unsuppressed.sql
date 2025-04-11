SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [Last VL Is Unsuppressed] = 'Yes'
        AND [Last Date Initiated EAC] IS NULL
    )
    AND (
        [Last Appointment in Previous Week] = 'Yes'
        OR [Last VL Result in Previous Week] = 'Yes'
    )