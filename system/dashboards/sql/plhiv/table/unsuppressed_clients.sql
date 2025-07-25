SELECT DISTINCT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Last Appointment Date_],
    [VL Result Return Date],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [ARV Regimen],
    [Now Pregnant/Breastfeeding],
    [Previous Date Initiated EAC],
    [Last Visit Type],
    [Last Visit Refill Type],
    [Days Missed Appointment],
    [ARV Regimen Description],
    [Current Height (CM)],
    [Current Weight (KG)],
    [BP Reading (Systolic)],
    [BP Reading (Diastolic)]
FROM
    duft.fact_unsuppressed_no_eac_clients