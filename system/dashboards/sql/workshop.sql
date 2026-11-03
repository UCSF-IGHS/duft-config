    SELECT
        [Patient ID],
        [Date of Birth],
        [Sex],
        [HIV Diagnosis Date] AS [Date Confirmed HIV],
        [Date Start ART],
        [Marital Status],
        CASE
            WHEN [Last Pregnancy Status] = 'Yes'
            THEN CONCAT([Last Pregnancy Status], ', ', [Pregnancy Due Date])
            ELSE [Last Pregnancy Status]
        END AS [Pregnancy Status],
        [Now Pregnant/Breastfeeding] AS [Breastfeeding Status],
        [Last VL Result Numeric] AS [Last Viral Load Result]
    FROM
        duft.fact_duft_sentinel_event