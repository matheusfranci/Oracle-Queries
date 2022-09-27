--Utilização
select a.tablespace_name,
to_char(nvl(a.used,0) / 1024 / 1024, 'FM999,990.00') MB_USED,
to_char(a.total / 1024 / 1024, 'FM999,990.00') MB_TOTAL,
to_char(nvl(used,0) * 100 / total, 'FM990.00') || '%' perc_used
from (select tablespace_name,
block_size,
(select SUM(v$sort_usage.blocks * block_size)
from v$sort_usage
where v$sort_usage.tablespace = dba_tablespaces.tablespace_name) USED,
(select sum(bytes)
from dba_temp_files
where tablespace_name = dba_tablespaces.tablespace_name) TOTAL
from dba_tablespaces
where contents = 'TEMPORARY') a;

----CRIAÇÃO DE TEMPORARY
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;

--Lembrando que não há como realizar o resize.
