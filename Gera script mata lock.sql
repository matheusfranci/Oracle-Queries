SELECT 'ALTER SYSTEM KILL SESSION ''' || SID || ',' || SERIAL# || ''' IMMEDIATE;'
FROM v$session s
WHERE s.status = 'INACTIVE'
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;
