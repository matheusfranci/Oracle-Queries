-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : ALERTAS.sql                                                                              #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024			                                                                         #
-- PROPOSITO  : analise dos alertas                                                                      #
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
SET lines 200
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


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
  --and blocking_session is not null 
  and d.seconds_in_wait/60 > 30 -- lock  mais de 30 minutos
ORDER BY 1 ASC, 5 Desc;