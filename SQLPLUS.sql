-- Adicionando linhas abaixo no arquivo:
set lines 160
set pages 50000
set time on
set timing on
set sqlprompt "_user'@'_connect_identifier> "

-- Queries de referência
column host_name heading "HOSTNAME" Format a15 JUSTIFY CENTER
column instance_name heading "INSTANCE" Format a15 JUSTIFY CENTER
column UPTIME heading "UPTIME" Format a21 JUSTIFY CENTER
column STATUS heading "STATUS" Format a10 JUSTIFY CENTER
column DATABASE_STATUS heading "DATABASE_STATUS" JUSTIFY CENTER
column INSTANCE_MODE heading "INSTANCE_MODE" Format a15 JUSTIFY CENTER
column DATABASE_TYPE heading "DATABASE_TYPE" JUSTIFY CENTER
column VERSION heading "VERSION" JUSTIFY CENTER
column ID format 99 JUSTIFY CENTER
SET UNDERLINE =
set colsep ' | '
select host_name, 
instance_name,
status ,
database_status,
instance_mode,
version,
DATABASE_TYPE,
'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' AS UPTIME
from v$instance;
