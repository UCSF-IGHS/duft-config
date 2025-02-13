SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM ctc_a_prod_analysis_test.sys.tables t
INNER JOIN ctc_a_prod_analysis_test.sys.schemas s ON t.schema_id = s.schema_id
-- ORDER BY s.name, t.name