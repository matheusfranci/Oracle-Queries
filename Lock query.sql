-- Single Instance
SET LINESIZE 500
SET PAGESIZE 1000
COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20
SELECT LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
s.osuser,
s.sid,
s.serial#,
s.lockwait,
s.status,
s.module,
s.machine,
s.program,
TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM v$session s
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;

-- Oracle RAC
SET LINESIZE 100
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN program FORMAT A45

SELECT s.inst_id,
       s.sid,
       s.serial#,
       --s.sql_id,
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND';
