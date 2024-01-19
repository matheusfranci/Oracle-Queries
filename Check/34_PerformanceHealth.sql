-- parametros sqlplus
SET SERVEROUTPUT ON
SET PAGESIZE 9999
SET LINESIZE 9999
SET FEEDBACK OFF
set heading on
set termout on
set sqlblanklines on
set markup html on spool on entmap off
SET ECHO OFF
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';
spo PerformanceCheck.html

ttitle center 'Hardware' skip 2
select STAT_NAME,to_char(VALUE) as VALUE ,COMMENTS from v$osstat where stat_name IN ('NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS')
union
select STAT_NAME,VALUE/1024/1024/1024 || ' GB' ,COMMENTS from v$osstat where stat_name IN ('PHYSICAL_MEMORY_BYTES');


ttitle center 'Optimizer Index Cost ADJ' skip 2
show parameter optimizer_index_cost_adj

ttitle center 'Optimizer Index Caching ' skip 2
show parameter optimizer_index_caching

ttitle center 'SGA_TARGET' skip 2
SHOW PARAMETER SGA_TARGET;

ttitle center 'SGA_MAX_SIZE' skip 2
SHOW PARAMETER SGA_MAX_SIZE;

ttitle center 'PGA_AGGREGATE_TARGET' skip 2
SHOW PARAMETER PGA_AGGREGATE_TARGET;

ttitle center 'DB_CACHE_SIZE' skip 2
SHOW PARAMETER DB_CACHE_SIZE;

ttitle center 'SHARED_POOL_SIZE' skip 2
SHOW PARAMETER SHARED_POOL_SIZE;

ttitle center 'LOG_BUFFER' skip 2
SHOW PARAMETER LOG_BUFFER;

ttitle center 'SORT_AREA_SIZE' skip 2
SHOW PARAMETER SORT_AREA_SIZE;

ttitle center 'SORT_AREA_RETAINED_SIZE' skip 2
SHOW PARAMETER SORT_AREA_RETAINED_SIZE;

ttitle center 'DB_WRITER_PROCESSES' skip 2
SHOW PARAMETER DB_WRITER_PROCESSES;

ttitle center 'LOG_WRITER' skip 2
SHOW PARAMETER LOG_WRITER;

ttitle center 'LOG_CHECKPOINTS_TO_ALERT' skip 2
SHOW PARAMETER LOG_CHECKPOINTS_TO_ALERT;

ttitle center 'FAST_START_MTTR_TARGET' skip 2
SHOW PARAMETER FAST_START_MTTR_TARGET;

ttitle center 'SESSION_CACHED_CURSORS' skip 2
SHOW PARAMETER SESSION_CACHED_CURSORS;

ttitle center 'OPTIMIZER_MODE' skip 2
SHOW PARAMETER OPTIMIZER_MODE;

ttitle center 'ArchiveLogMode' skip 2
select log_mode from v$database;

ttitle center 'Uptime' skip 2
select 'Hostname : ' || host_name ,'Instance Name : ' || instance_name ,'Started At : ' || to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') stime ,'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' || trunc( 24*((sysdate-startup_time) - trunc(sysdate-startup_time))) || ' hour(s) ' || mod(trunc(1440*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' minute(s) ' || mod(trunc(86400*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' seconds' uptime from sys.v_$instance;

ttitle center 'Database Size' skip 2
select sum(bytes) /1073741824  TAMANHO_GB from dba_segments;

ttitle center 'ESTADO DAS TABLESPACES' skip 2
select
   fs.tablespace_name                                               "Tablespace",
   round(df.totalspace - fs.freespace)                              "Used MB",
   round(fs.freespace)                                              "Free MB",
   round(100 * (fs.freespace / df.totalspace))                      "Pct. Free %",
   round(df.totalspace)                                             "Total MB",
   round(tb.maxbytes)                                               "Max extend MB"
   --, round(100 - (100 * (df.totalspace / tb.maxbytes)))           "Pct. Extend %"
   from
   (select tablespace_name, sum(bytes/1024)/1024 TotalSpace from dba_data_files
   group by tablespace_name) df,
   (select tablespace_name, sum(bytes/1024)/1024 FreeSpace  from dba_free_space
   group by tablespace_name) fs,
   (select tablespace_name, sum(maxbytes/1024)/1024 maxbytes from dba_data_files
   group by tablespace_name) tb
where 
   df.tablespace_name = fs.tablespace_name 
   and
   df.tablespace_name = tb.tablespace_name order by "Max extend MB" asc; 

ttitle center 'Temp Tablespace Usage' skip 2
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


ttitle center 'Undo usage' skip 2
select tablespace_name tablespace, status, sum(bytes)/1024/1024 sum_in_mb, count(*) counts
from dba_undo_extents
group by tablespace_name, status order by 1,2;

ttitle center 'Sessions Running 5 minutes ' skip 2
SELECT sid,serial#,inst_id,process,osuser,schemaname,machine,status,program,sql_id,sql_exec_start,
to_char(logon_time,'dd-mm-yy hh:mi:ss AM')"Logon Time",
ROUND((SYSDATE-LOGON_TIME)*(24*60),1) as LOGGED_ON_MIN,
ROUND(LAST_CALL_ET/60,1) as CURRENT_SQL_MIN
From gv$session
WHERE STATUS='ACTIVE'
AND USERNAME IS NOT NULL
AND TYPE = 'USER'
and ROUND(LAST_CALL_ET/60,1) > 5 -- more than 5 minutes
ORDER BY LAST_CALL_ET DESC ;

ttitle center 'Redo Switch' skip 2
COLUMN day FORMAT A12
COLUMN "00" FORMAT 999
COLUMN "01" FORMAT 999
COLUMN "02" FORMAT 999
COLUMN "03" FORMAT 999
COLUMN "04" FORMAT 999
COLUMN "05" FORMAT 999
COLUMN "06" FORMAT 999
COLUMN "07" FORMAT 999
COLUMN "08" FORMAT 999
COLUMN "09" FORMAT 999
COLUMN "10" FORMAT 999
COLUMN "11" FORMAT 999
COLUMN "12" FORMAT 999
COLUMN "13" FORMAT 999
COLUMN "14" FORMAT 999
COLUMN "15" FORMAT 999
COLUMN "16" FORMAT 999
COLUMN "17" FORMAT 999
COLUMN "18" FORMAT 999
COLUMN "19" FORMAT 999
COLUMN "20" FORMAT 999
COLUMN "21" FORMAT 999
COLUMN "22" FORMAT 999
COLUMN "23" FORMAT 999
SELECT TO_CHAR(first_time, 'YYYY-MM-DD') AS day,
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '00', 1, 0)), '999') AS "00",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '01', 1, 0)), '999') AS "01",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '02', 1, 0)), '999') AS "02",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '03', 1, 0)), '999') AS "03",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '04', 1, 0)), '999') AS "04",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '05', 1, 0)), '999') AS "05",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '06', 1, 0)), '999') AS "06",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '07', 1, 0)), '999') AS "07",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '08', 1, 0)), '999') AS "08",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '09', 1, 0)), '999') AS "09",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '10', 1, 0)), '999') AS "10",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '11', 1, 0)), '999') AS "11",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '12', 1, 0)), '999') AS "12",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '13', 1, 0)), '999') AS "13",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '14', 1, 0)), '999') AS "14",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '15', 1, 0)), '999') AS "15",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '16', 1, 0)), '999') AS "16",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '17', 1, 0)), '999') AS "17",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '18', 1, 0)), '999') AS "18",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '19', 1, 0)), '999') AS "19",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '20', 1, 0)), '999') AS "20",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '21', 1, 0)), '999') AS "21",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '22', 1, 0)), '999') AS "22",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '23', 1, 0)), '999') AS "23"
FROM v$log_history
WHERE first_time >= SYSDATE - INTERVAL '10' DAY
GROUP BY TO_CHAR(first_time, 'YYYY-MM-DD')
ORDER BY day DESC;

ttitle center 'Buffer Cache' skip 2
SELECT ROUND((1-(phy.value / (cur.value + con.value)))*100,2) "Cache Hit Ratio"
FROM v$sysstat cur,
v$sysstat con,
v$sysstat phy
WHERE cur.name = 'db block gets'
AND con.name = 'consistent gets'
AND phy.name = 'physical reads';

ttitle center 'Lock' skip 2
select round(s.last_call_et / 60, 0) minutos,
       s.status,
       s.logon_time,
       'kill -9 ' || p.spid as OSPID,
       s.inst_id,
       'alter system kill session ''' || s.sid || ',' || s.serial# || ',' || '@' || s."INST_ID" ||  ''' immediate;' SID_SERIAL#,
       s.blocking_instance || ' - ' || s.blocking_session BLOQ,
       s.program,
       s.machine,
       s.osuser,
       s.username,
       s.event,
       s.prev_sql_id,
       s.sql_id,
       a.sql_fulltext,
       a.sql_text
  from gv$session s
  join gv$sqlarea a
    on s.inst_id = a.inst_id
   and s.sql_id = a.sql_id
  join gv$process p
    on s.inst_id = p.inst_id
   and s.paddr = p.addr
 where s.osuser <> 'oracle'
   and s.status = 'ACTIVE'
   and s.osuser <> 'wabp'
 order by s.last_call_et desc;

ttitle center 'BLOQUEIO DE SESSOES' skip 2
select  'ALTER SYSTEM KILL SESSION '||chr(39)||session_id||','||SERIAL#||',@'||c.inst_id||';' "sql pronto",
substr(object_name,1,20) "Object",
  substr(os_user_name,1,10) "Terminal",
  substr(oracle_username,1,10) "Locker",
  nvl(lockwait,'active') "Wait",
  decode(locked_mode,
    2, 'row share',
    3, 'row exclusive',
    4, 'share',
    5, 'share row exclusive',
    6, 'exclusive',  'unknown') "Lockmode",
  OBJECT_TYPE "Type",
   d.seconds_in_wait/60 "Minutos",
blocking_Session
FROM
  SYS.GV_$LOCKED_OBJECT A,
  SYS.ALL_OBJECTS B,
  SYS.GV_$SESSION C,
  sys.GV_$SESSION_WAIT D
WHERE
  A.OBJECT_ID = B.OBJECT_ID AND
  C.SID = A.SESSION_ID  and 
  C.SID = D.SID
  and blocking_session is not null 
ORDER BY 1 ASC, 5 Desc;


ttitle center 'BLOQUEIO DE SESSOES COM MAIS DE 30 MINUTOS' skip 2
select  'ALTER SYSTEM KILL SESSION '||chr(39)||session_id||','||SERIAL#||',@'||c.inst_id||';' "sql pronto",
substr(object_name,1,20) "Object",
  substr(os_user_name,1,10) "Terminal",
  substr(oracle_username,1,10) "Locker",
  nvl(lockwait,'active') "Wait",
  decode(locked_mode,
    2, 'row share',
    3, 'row exclusive',
    4, 'share',
    5, 'share row exclusive',
    6, 'exclusive',  'unknown') "Lockmode",
  OBJECT_TYPE "Type",
   d.seconds_in_wait/60 "Minutos",
blocking_Session
FROM
  SYS.GV_$LOCKED_OBJECT A,
  SYS.ALL_OBJECTS B,
  SYS.GV_$SESSION C,
  sys.GV_$SESSION_WAIT D
WHERE
  A.OBJECT_ID = B.OBJECT_ID AND
  C.SID = A.SESSION_ID  and 
  C.SID = D.SID
  and d.seconds_in_wait/60 > 30 -- lock  mais de 30 minutos
ORDER BY 1 ASC, 5 Desc;

ttitle center 'PGA Hit Cache' skip 2
SELECT
ROUND(pga_target_for_estimate /(1024*1024))pga_target_for_estimate ,
estd_pga_cache_hit_percentage ,
estd_overalloc_count 
FROM
v$pga_target_advice;

ttitle center 'Hit Ratio' skip 2
select to_char(round(value,4),'999.99') ||'%' "PGA Hit Ratio"
from sys.v_$pgastat
where name = 'cache hit percentage';

ttitle center 'Wait sessions' skip 2
select
   WAIT_CLASS,
   TOTAL_WAITS,
   round(100 * (TOTAL_WAITS / SUM_WAITS),2) PCT_WAITS,
   TIME_WAITED,
   round(100 * (TIME_WAITED / SUM_TIME),2) PCT_TIME
from
(select WAIT_CLASS,
   TOTAL_WAITS,
   TIME_WAITED
 from
   V$SYSTEM_WAIT_CLASS
where
   WAIT_CLASS != 'Idle'),
(select
   sum(TOTAL_WAITS) SUM_WAITS,
   sum(TIME_WAITED) SUM_TIME
from
   V$SYSTEM_WAIT_CLASS
where
   WAIT_CLASS != 'Idle')
order by 5 desc;

ttitle center 'CPU USED BY SESSION' skip 2
 COLUMN value FORMAT 99999999999 HEADING "VALUE"
 SELECT n.username, s.sid, s.value/100 cpu_usage_seconds  FROM v$sesstat s,v$statname t, v$session n
 WHERE s.statistic# = t.statistic# and ROWNUM <= 10
 AND n.sid = s.sid
 AND t.name='CPU used by this session'
 and n.status='ACTIVE'
 ORDER BY s.value desc;
 
ttitle center 'Validating the Database and Wait Time ratio' skip 2
 COLUMN metric_name       FORMAT a40              HEADING 'METRIC_NAME'
 COLUMN metric_unit       FORMAT a30           HEADING 'METRIC_UNIT'
 COLUMN inst_id           FORMAT 99               HEADING 'inst_id'          JUSTIFY right
 COLUMN intsize_csec      FORMAT 999999999.99              HEADING 'INTSIZE_CSEC'     JUSTIFY right
 COLUMN VALUE             FORMAT 999999999.99               HEADING 'VALUE'        JUSTIFY right
 COLUMN BEGIN_TIME        FORMAT 9999999          HEADING 'begin_time'         JUSTIFY right
 COLUMN end_time          FORMAT a20              HEADING 'end_time' TRUNC
 select  METRIC_NAME,metric_unit,INST_ID,INTSIZE_CSEC,
        VALUE,begin_time ,end_time
 from    GV$SYSMETRIC
 where   METRIC_NAME IN ('Database CPU Time Ratio',
                        'Database Wait Time Ratio')
                        AND
        (INTSIZE_CSEC ,inst_id ) in
        (select max(INTSIZE_CSEC),inst_id  from GV$SYSMETRIC group by inst_id )   order by 3 ;

ttitle center 'Waits' skip 2
SET LINESIZE 145
 SET PAGESIZE 9999
 COLUMN wait_class        FORMAT a20              HEADING 'WAIT_CLASS'
 COLUMN inst_id           FORMAT 99               HEADING 'INST_ID'          JUSTIFY right
 COLUMN BEGIN_TIME        FORMAT 9999999          HEADING 'BEGIN_TIME'         JUSTIFY left
 COLUMN end_time          FORMAT 9999999          HEADING 'END_TIME'             JUSTIFY left
 COLUMN dbtime_in_wait    FORMAT 9999.99          HEADING 'DBTIME_IN_WAIT'     JUSTIFY right
 COLUMN time_waited       FORMAT 9999999.99          HEADING 'TIME_WAITED'        JUSTIFY right

ttitle center 'The waits are from which wait classes  ' skip 2
 select b.wait_class ,a.inst_id ,a.begin_time ,
 a.end_time , a.dbtime_in_wait , a.time_waited from GV$WAITCLASSMETRIC a , gV$SYSTEM_WAIT_CLASS b where
 a.wait_class_id = b.wait_class_id
 and  a.inst_id =1
 and a.inst_id = b.inst_id
 --- and b.wait_class='Commit'
 order by 5 desc ;
 prompt
 
 spo off
