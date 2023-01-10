SELECT 'ALTER SYSTEM KILL SESSION ''' || SID || ',' || SERIAL# || ''' IMMEDIATE;'
FROM v$session s
WHERE s.status = 'INACTIVE'
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;


--RAC
 select 'alter system kill session '''||v$session.sid||','||v$session.serial#||',@'||gv$session.inst_id||'''IMMEDIATE;' as script from gv$session, v$session 
WHERE v$session.status = 'INACTIVE'
CONNECT BY PRIOR v$session.sid = v$session.blocking_session
START WITH v$session.blocking_session IS NULL;
