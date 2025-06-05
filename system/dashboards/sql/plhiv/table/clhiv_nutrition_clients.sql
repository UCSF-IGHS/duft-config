SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Next Appointment Date],
    [Current Weight(KG)],
    [Current Height(CM)],
    [Documented Nutritional Status],
    [Calculated Nutritional Status],
    [Documented and Calculated Nutritional Status Match]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Current Age] < 5
    -- AND
    --     [Last Visit in Previous Week] = 'Yes'
    AND
        (
            [Current Weight(KG)] IS NULL
            OR [Current Height(CM)] IS NULL
            OR [Documented Nutritional Status] IS NULL
            OR [Documented and Calculated Nutritional Status Match] = 'No'
        )