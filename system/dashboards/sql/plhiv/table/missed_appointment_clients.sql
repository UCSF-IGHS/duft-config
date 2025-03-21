SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date] AS [Missed Appointment Date],
    [Number of Days Prescribed],
    [Last Appointment Documented Status],
    [Now Pregnant/Breastfeeding],
    NULL AS [TB Suspect],
    [Last VL Is Unsuppressed] AS [High VL]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 'Yes'
AND
    [Last Appointment in Previous Week] = 'Yes'
AND
    [Last Visit in Previous Week] = 'No'
ORDER BY
    [Patient ID] ASC