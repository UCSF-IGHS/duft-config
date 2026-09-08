SELECT DISTINCT
    fdse.[Patient ID],
    fdse.[Current Age],
    fdse.[Sex],
    fdse.[Date Start ART],
    fdse.[Last Visit Date],
    fdse.[Number of Days Dispensed],
    fdse.[Last Appointment Date] AS [Missed Appointment Date],
    fdse.[Now Pregnant/Breastfeeding],
    fdse.[Last VL Is Unsuppressed] AS [Last Viral Load High(>1000cps/ml)],
    fdse.[Last Visit Type],
    fdse.[Last Visit Refill Type],
    fdse.[Days Missed Appointment],
    fdse.[Last Prescription Regimen Name] AS [ARV Regimen Description],
    fdse.[Current Height (CM)],
    fdse.[Current Weight (KG)],
    fdse.[Last BP Systolic] AS [BP Reading (Systolic)],
    fdse.[Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event fdse
INNER JOIN
    [derived].fact_ctc_daily_client_status fcdcs
    ON fcdcs.client_id = fdse.[Client ID]
WHERE
    fdse.[Last Appointment Date] <= GETDATE()
    AND fcdcs.is_transferred_out IS NULL
    AND DATEDIFF(
        DAY,
        fdse.[Last Visit Date],
        fdse.[Last Appointment Date]
    ) > 10;