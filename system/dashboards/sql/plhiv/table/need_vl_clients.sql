SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [ART Initiation Date] AS [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [Now Pregnant/Breastfeeding],
    [VL Eligible Post EAC],
    [VL Eligible PGBF],
    [VL Eligible TX_CURR],
    [VL Eligible TX_NEW]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 'Yes'
AND
    [Last Appointment in Previous Week] = 'Yes'
ORDER BY
    [Patient ID] ASC