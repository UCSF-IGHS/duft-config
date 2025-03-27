SELECT
    [Patient ID],
    [Current Age],
    [Sex],
    [Date Start ART],
    [Last Visit Date],
    [Current Weight],
    [Current Weight],
    [Documented Nutritional Status],
    [Calculated Nutritional Status],
    [Documented and Calculated Nutritional Status Match]
FROM
    duft.fact_duft_sentinel_event
WHERE
    [Current Age] < 15
AND
    [Last Visit in Previous Week] = 'Yes'
ORDER BY
    [Patient ID] ASC