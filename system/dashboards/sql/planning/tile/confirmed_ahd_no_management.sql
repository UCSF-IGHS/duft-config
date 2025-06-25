SELECT
    COUNT(*)
FROM
    duft.fact_duft_sentinel_event
WHERE
    (
        [CrAg Test Results] = 'Pos'
        AND (
            [CI Received Cryptococcal Prophylaxis] = 'No'
            OR [CM Received Cryptococcal Treatment] = 'No'
        )
    )
