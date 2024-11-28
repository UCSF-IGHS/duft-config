SELECT
    [CTC ID],
    [Current Age],
    [DOB],
    [Sex],
    [Last VL Test Date],
    [Last VL Result Numeric],
    [Last VL Result Text],
    [Last VL Result Date],
    [Last VL Is Unsuppressed],
    [Last Date Initiated EAC]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Last VL Is Unsuppressed] = 'Yes'
ORDER BY
    [CTC ID] ASC