SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Months],
    [Sex],
    [Last Visit Date],
    [DNA PCR Test Results at Birth],
    [DNA PCR Test Results at 4 to 6 Weeks],
    [DNA PCR Test Results at 9 Months],
    [Antibody Test Results at 3 Months Post-BF]
    FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Has Final Outcome] = 'No'
AND
    [HEI Current Age in Months] BETWEEN 18 AND 24
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
ORDER BY
    [Patient ID]