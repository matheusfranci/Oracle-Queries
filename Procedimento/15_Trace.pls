ALTER SESSION SET SQL_TRACE = TRUE


EXEC sys.dbms_system.set_sql_trace_in_session (1, 54895, TRUE);

-- Todas as sessões
alter system set events '10046 TRACE NAME CONTEXT FOREVER, LEVEL 4';
