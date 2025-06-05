SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Months],
    [Sex],
    [Last Visit Date],
    [HEI Eligible for DNA PCR at 9 Months],
    [DNA PCR at 9 Months Sample Collection Date],
    [Antibody Test Results at 3 Months Post-BF],
    [Antibody Test Date at 3 Months Post-BF],
    [Antibody Test Results at 18 Months],
    [Antibody Test Date at 18 Months]
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Need EID Test 9 Months] = 'Yes'
    AND ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')
    -- AND [HEI Current Age in Months] = 9