-- Verificando última coleta de estatísticas
COLUMN table_name FORMAT A30
COLUMN last_analyzed FORMAT A30
SELECT table_name, last_analyzed
FROM all_tab_statistics
WHERE owner = 'schemaname';

-- Coletando apenas de um schema
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('schemaname',CASCADE=>TRUE);
