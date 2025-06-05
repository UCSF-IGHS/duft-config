SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Last Prescription Regimen Line] AS [ARV Regimen],
    [Now Pregnant/Breastfeeding] AS [Now Pregnant/ Breastfeeding],
    [Last VL Test Date] AS [VL Test Date Before Start EAC],
    [Last VL Result Numeric] AS [VL Result Before Start EAC],
    [Last VL Result Date] AS [VL Result Return Date],
    [Last Date Initiated EAC] AS [Previous Date Initiated EAC]
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [Last VL Is Unsuppressed] = 'Yes'
        AND [Last Date Initiated EAC] IS NULL
    )