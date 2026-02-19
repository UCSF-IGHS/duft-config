SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Registered Using Biometrics],
    [Missed Biometric Verification],
    [Missed Biometric Verification Reason],
    [Last Appointment Date] AS [Missed Appointment Date],
    [Now Pregnant/Breastfeeding],
    [Last Visit Type],
    [Current Height (CM)],
    [Current Weight (KG)],
    [Last BP Systolic] AS [BP Reading (Systolic)],
    [Last BP Diastolic] AS [BP Reading (Diastolic)]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Biometric Verification] = 'Yes'