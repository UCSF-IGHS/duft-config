SELECT
    COUNT(*)
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
--     [Date Of Birth in Previous Week] = 'Yes'
-- AND
    [HEI Registered] = 'No'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')