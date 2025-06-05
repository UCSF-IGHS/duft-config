SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Last Visit Date],
    [Number of Days Dispensed],
    [Next Appointment Date],
    [Days Since Last Visit],
    [Days Missed Drugs]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Missed Drugs 29-90 Days] = 'Yes'