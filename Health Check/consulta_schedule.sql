-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : consulta_schedule.sql                                                                    #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : Jobs agendados                                                                           #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
set heading on
set termout on
SET lines 200
set colsep |
set markup html on spool on entmap off

column "owner" format a16
column "job_name"    format a40
column "PROGRAM_NAME"    format a26
column "SCHEDULE_NAME"   format a26
column "job"   format a8
column "SCHEMA_USER"   format a16
column "INTERVAL"   format a30
column "LAST_DATE||LAST_SEC"   format a20
column "LAST_DATE"   format a10
column "LAST_SEC"   format a10
column "BROKEN"   format a2

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

ttitle center 'Informacoes sobre os schedules' skip 2
select owner, job_name, PROGRAM_NAME, SCHEDULE_NAME, 
to_char(LAST_START_DATE, 'dd/mm/yyyy hh24:mi:ss') as "data ultima execucao",
to_char(NEXT_RUN_DATE, 'dd/mm/yyyy hh24:mi:ss') as "data proxima execucao" 
FROM dba_scheduler_jobs; 

column "job"   format a8
column "SCHEMA_USER"   format a16
column "INTERVAL"   format a30
column "LAST_DATE||LAST_SEC"   format a20
column "LAST_DATE"   format a10
column "LAST_SEC"   format a10
column "BROKEN"   format a2
ttitle center 'Informações sobre os jobs' skip 2
select job as "numero do job", 
SCHEMA_USER as "dono do job",
LAST_DATE||LAST_SEC as "ultima execucao", 
INTERVAL as "intervalo", 
BROKEN 
from dba_jobs;


