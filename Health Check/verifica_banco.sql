-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : VERIFICA_BANCO.sql                                                                       #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024			                                                                         #
-- PROPOSITO  : identificas os principais parametros do banco                                            #
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
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


column "INSTANCE_NUMBER" format a2
column "INSTANCE_NAME"    format a10
column "VERSION"    format a10
column "STARTUP_TIME"   format a12
column "STATUS"   format a10
column "DATABASE_STATUS"   a14
column "archiver"   format a16
ttitle center 'DATABASE' skip 2
select inst_id, DBID, NAME "NOME", LOG_MODE "LOG", OPEN_MODE "STATUS", CURRENT_SCN, FLASHBACK_ON, FORCE_LOGGING from gv$database;


ttitle center 'INSTANCE' skip 2
select inst_id, 
INSTANCE_NUMBER AS SOMENTE_RAC,HOST_NAME "SERVIDOR",
INSTANCE_NAME "INSTANCIA",
VERSION "VERSAO",
STARTUP_TIME "START_TIME",
STATUS,
DATABASE_STATUS "DB_ESTADO",
archiver "ARCHIVE_LOG"
from  GV$INSTANCE;


ttitle center 'CONTROLFILE' skip 2
SELECT * FROM V$CONTROLFILE;


ttitle center 'REGISTRY' skip 2
select comp_id as "componente ID", comp_name as "nome do componente", status  from DBA_REGISTRY;


ttitle center 'TAMANHO LOG_FILES' skip 2
select c.instance_name,a.type,a.member,(b.bytes/1024)/1024,b.sequence#,b.archived,b.status 
from gv$logfile a, gv$log b, GV$INSTANCE c 
where a.group# = b.group# and
a.INST_ID = b.INST_ID 
and a.INST_ID = c.INST_ID 
order by b.SEQUENCE#;


ttitle center 'FREQUENCIA DOS SWITCHS LOG_FILES' skip 2
set lines 132
column day format a16  heading 'Day'
column d_0 format a3  heading '00'
column d_1 format a3  heading '01'
column d_2 format a3  heading '02'
column d_3 format a3  heading '03'
column d_4 format a3  heading '04'
column d_5 format a3  heading '05'
column d_6 format a3  heading '06'
column d_7 format a3  heading '07'
column d_8 format a3  heading '08'
column d_9 format a3  heading '09'
column d_10 format a3  heading '10'
column d_11 format a3  heading '11'
column d_12 format a3  heading '12'
column d_13 format a3  heading '13'
column d_14 format a3  heading '14'
column d_15 format a3  heading '15'
column d_16 format a3  heading '16'
column d_17 format a3  heading '17'
column d_18 format a3  heading '18'
column d_19 format a3  heading '19'
column d_20 format a3  heading '20'
column d_21 format a3  heading '21'
column d_22 format a3  heading '22'
column d_23 format a3  heading '23'
column  Total   format 9999
column status  format a8
column member  format a40
column archived heading "Archived" format a8
column bytes heading "Bytes|(MB)" format 9999
prompt

select 
b.instance_number,
b.instance_name
,substr(to_char(a.FIRST_TIME,'DD-MM-YYYY'),1,15) "DATA",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'00',1,0))) "00",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'01',1,0))) "01",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'02',1,0))) "02",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'03',1,0))) "03",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'04',1,0))) "04",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'05',1,0))) "05",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'06',1,0))) "06",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'07',1,0))) "07",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'08',1,0))) "08",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'09',1,0))) "09",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'10',1,0))) "10",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'11',1,0))) "11",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'12',1,0))) "12",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'13',1,0))) "13",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'14',1,0))) "14",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'15',1,0))) "15",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'16',1,0))) "16",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'17',1,0))) "17",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'18',1,0))) "18",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'19',1,0))) "19",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'20',1,0))) "20",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'21',1,0))) "21",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'22',1,0))) "22",
         decode(sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(a.FIRST_TIME,'HH24'),1,2),'23',1,0))) "23"
from     gv$log_history a, gv$instance b
where a.inst_id = b.inst_id
and a.FIRST_TIME > (sysdate -10)
group by substr(to_char(a.FIRST_TIME,'DD-MM-YYYY'),1,15),instance_number,b.instance_name
order by substr(to_char(a.FIRST_TIME,'DD-MM-YYYY'),1,15) desc;


ttitle center 'Standby log files' skip 2
SELECT GROUP#, (BYTES/1024)/1024, USED, STATUS FROM GV$STANDBY_LOG;


ttitle center 'SEQUENCIAS' skip 2
SELECT LAST_NUMBER, MAX_VALUE,  MAX_VALUE-LAST_NUMBER QUANTO_FALTA , 100 - ( ROUND(((LAST_NUMBER*100)/(MAX_VALUE)),2)) PORCENTAGEM_FALTANTE
FROM DBA_SEQUENCES
WHERE 100 - ( ROUND(((LAST_NUMBER*100)/(MAX_VALUE)),2)) < 20
AND cycle_flag = 'N';



