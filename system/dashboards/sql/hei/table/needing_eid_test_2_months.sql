SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Age in Weeks at Last Visit],
    [Sex],
    [Last Visit Date],
    [Documented Risk Category],
    [HEI Eligible for DNA PCR at Birth],
    [DNA PCR at Birth Sample Collection Date],
    [HEI Eligible for DNA PCR at 4 to 6 Weeks],
    [DNA PCR at 4 to 6 Weeks Sample Collection Date]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    (
        (
            [Last Appointment in Previous Week] = 'Yes'
            AND [HEI Eligible for DNA PCR at Birth] = 'Yes'
            AND [DNA PCR at Birth Sample Collection Date] IS NULL
        )
        OR
        (
            [HEI Eligible for DNA PCR at 4 to 6 Weeks] = 'Yes'
            AND [DNA PCR at 4 to 6 Weeks Sample Collection Date] IS NULL
        )
    )
    AND ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]