SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Days],
    [Sex],
    [Last Visit Date],
    [HEI Documented Risk Category],
    [HEI Calculated Risk Status],
    [Misclassified High Risk HEI],
    [HEI Given ABC/3TC+NVP Prophylaxis],
    [HEI Given Nevirapine],
    [HEI Given CTX],
    [Last Mother HVL Date],
    [Last Mother HVL Results],
    [Date Mother Start ART],
    [Last Derived Appointment Status],
    [Number of Weeks Mother on ART Before Delivery],
    [Diagnosed with HIV During Pregnancy or Breastfeeding]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Date of Birth in Previous Week] = 'Yes'
AND
    [Misclassified High Risk HEI] = 'Yes'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]