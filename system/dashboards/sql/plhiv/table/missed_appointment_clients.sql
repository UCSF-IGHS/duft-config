SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Last Appointment Date] AS [Missed Appointment Date],
    --Days Prescribed
    --Last Documented
    [Now Pregnant/Breastfeeding],
    -- [TB Suspect]
    [Has High VL Post EAC] --!?
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