SELECT
    [CTC ID],
    [Current Age],
    [DOB],
    [Sex],
    [Last Visit Date],
    [Last Prescription Date],
    [Number of Days Prescribed],
    [Days Since Last Visit],
    [Drug Days Left],
    [Should Have Drugs],
    [Days Missed Drugs],
    [Missed Drugs 1+ Days],
    [Missed Drugs 29+ Days],
    [Missed Drugs 29-90 Days]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Drugs 29-90 Days] = 1
ORDER BY
    [Days Missed Drugs] ASC