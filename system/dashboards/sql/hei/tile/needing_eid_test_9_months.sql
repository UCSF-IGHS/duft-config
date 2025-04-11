SELECT 
    COUNT(*) 
FROM
    duft.fact_duft_hei_sentinel_event
WHERE
    (
        (
           [HEI Eligible for DNA PCR at 9 Months] = 'Yes'
            AND [DNA PCR at 9 Months Sample Collection Date] IS NULL
        )
        AND (
			 [Antibody Test Date at 3 Months Post-BF] IS NULL
        )
    )
AND
    ISNULL([Infant Status], '') NOT IN ('TRN', 'DIE')