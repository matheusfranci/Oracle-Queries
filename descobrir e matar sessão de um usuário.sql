select s.sid, s.serial#, s.status, p.spid
from v$session s, v$process p
where s.username = 'myuser'
and p.addr (+) = s.paddr;

-- alter system kill session '<sid>,<serial#>';
