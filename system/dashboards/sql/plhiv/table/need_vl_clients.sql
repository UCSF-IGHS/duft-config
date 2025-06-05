SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Now Pregnant/Breastfeeding] AS [Now Pregnant/ Breastfeeding],
    [Last VL Test Date],
    [Last VL Result Numeric] AS [Last VL Result],
    [VL Eligible PGBF] AS [VL Eligible PBFW],
    [VL Eligible TX_CURR],
    [VL Eligible TX_NEW]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 'Yes'