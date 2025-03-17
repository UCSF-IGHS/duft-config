SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [VL Results 50 - 999 cps/ml],
    [VL Results >= 1000 cps/ml],
    [Next Appointment Date],
    [VL Eligible PGBF],
    [VL Eligible TX_CURR],
    [VL Eligible TX_NEW],
    [Needs VL Test]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 'Yes'
ORDER BY
    [Patient ID] ASC