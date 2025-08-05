SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Last VL Test Date],
    [Last VL Result Numeric] AS [Last VL Result],
    [VL Eligible PGBF] AS [VL Eligible PBFW],
    [VL Eligible TX_CURR],
    [VL Eligible TX_NEW],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Last Prescription Regimen Name] AS [ARV Regimen Description],
    [Eligible Next Week],
    [Eligible for HVL Next Week],
    [Eligible for EAC Next Week],
    [Eligible for CD4 Next Week],
    [Eligible for CrAg Next Week],
    [Eligible for CPeT Next Week],
    [Eligible for CMT Next Week],
    [Became Eligible for EAC Date],
    [Became Eligible for CD4 Date],
    [Became Eligible for CrAg Date],
    [Became Eligible for CPeT Date],
    [Became Eligible for CMT Date],
    [Current Height (CM)],
    [Current Weight (KG)],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Eligible Next Week] = 'Yes'
AND
    [Next Appointment in Next Week] = 'Yes'