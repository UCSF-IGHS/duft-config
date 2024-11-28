SELECT
    [CTC ID],
    [Current Age],
    [DOB],
    [Sex],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [Last VL Result Text],
    [Last VL Is Suppressed],
    [VL Eligible PGBF],
    [VL Eligible TX_CURR],
    [VL Eligible TX_NEW],
    [Needs VL Test]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Needs VL Test] = 1
ORDER BY
    [CTC ID] ASC