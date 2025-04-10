SELECT
    DISTINCT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Number of Days Prescribed] AS [Number of Days Dispensed],
    [Last Appointment Date] AS [Missed Appointment Date],
    [Number of Days Dispensed],
    [Last Documented Appointment Status],
    [Now Pregnant/Breastfeeding],
    NULL AS [TB Suspect],
    [Last VL Is Unsuppressed] AS [High VL]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last Visit in Previous Week] = 'No'
ORDER BY
    [Last Appointment Date] ASC