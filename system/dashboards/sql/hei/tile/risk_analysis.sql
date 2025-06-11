SELECT COUNT(*)
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    [Date of Birth in Previous Week] = 'Yes'
AND
    [Misclassified High Risk HEI] = 'Yes'
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')