SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [ART Initiation Date],
    [Last Visit Date],
    [Last VL Test Date],
    [Now Pregnant/Breastfeeding],
    [Last VL Result Date],
    [Last VL Result Numeric],
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