SELECT
    COUNT(DISTINCT([Patient ID]))
FROM
    duft.fact_duft_sentinel_event
-- WHERE
--     [Last Appointment in Previous Week] = 'Yes'
-- AND
--     [Last Visit in Previous Week] = 'No'