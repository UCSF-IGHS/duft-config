SELECT
    COUNT(DISTINCT fdse.[Patient ID])
FROM
    duft.fact_duft_sentinel_event fdse
INNER JOIN
    [derived].fact_ctc_daily_client_status fcdcs
    ON fcdcs.client_id = fdse.[Client ID]
WHERE
    fdse.[Last Appointment Date] = $[Last Appointment Date%r]
    AND fcdcs.is_transferred_out IS NULL
    AND DATEDIFF(
        DAY,
        fdse.[Last Visit Date],
        fdse.[Last Appointment Date]
    ) > 10;