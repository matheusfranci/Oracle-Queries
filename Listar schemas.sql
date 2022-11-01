-- Listando schemas
select distinct owner schema_name
from dba_segments
where owner in(select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX'))
order by owner;

-- Mudando de schema
ALTER SESSION SET CURRENT_SCHEMA=ZEUSMANAGER;

-- Verificando schema atual
select sys_context( 'userenv', 'current_schema' ) from dual;
