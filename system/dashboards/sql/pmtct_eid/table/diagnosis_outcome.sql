
SELECT
    [Mother Patient ID],
    [Exposed Infant ID],
    [Date of Birth],
    [HEI Current Age in Months],
    [Sex],
    [Week End Date],
    [Last Visit Date],
    [First Test Date],
    [First Test Results],
    [HEI Registered at Birth],
    [4 to 6 Weeks HEI Eligible for DNA PCR Test],
    [9 Months HEI Eligible for DNA PCR Test],
    [3 Months Post BF HEI Eligible for DNA PCR Test],
    [18 Months HEI Eligible for DNA PCR Test],
    [HEI Eligible and Attended],
    [HEI Attended and Sample Taken],
    [HEI with No Documented DNA PCR Test]
FROM
    duft.fact_duft_pmtct_eid_clients
