SELECT
    s.name AS [Schema Name],
    t.name AS [Table Name],
    CONCAT(s.name, '.', t.name) AS [Copy For Database]
FROM ctc_a_prod_analysis_test.sys.tables t
INNER JOIN ctc_a_prod_analysis_test.sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name