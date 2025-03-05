SELECT
    [CTC ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Last VL Test Date],
    [Last VL Result Numeric],
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
    [CTC ID] ASC