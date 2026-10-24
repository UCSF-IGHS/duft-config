
SELECT
    [Patient ID] AS [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Months],
    [Sex],
    [Last Visit Date] AS [Last Visit Date],
    [First EID Test Date] AS [First Test Date],
    [First EID Result] AS [First Test Results],
    [HEI Registered] AS [HEI Registered at Birth],
    [4 to 6 Weeks HEI Eligible for DNA PCR Test],
    [9 Months HEI Eligible for DNA PCR Test],
    [3 Months Post BF HEI Eligible for DNA PCR Test],
    [18 Months HEI Eligible for DNA PCR Test],
    [HEI Eligible and Attended],
    [HEI Attended and Sample Taken],
    [HEI with Undocumented DNA PCR Test]
FROM
    duft.fact_duft_hei_sentinel_event
    