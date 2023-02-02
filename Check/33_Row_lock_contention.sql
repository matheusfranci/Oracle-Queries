select * from dba_hist_active_sess_history where event like 'enq: TX - row lock contention%' order by sample_time desc


SELECT DISTINCT a.sid "waiting sid" ,
a.event ,
c.sql_text "SQL from blocked session" ,
b.sid "blocking sid" ,
b.event ,
b.sql_id ,
b.prev_sql_id ,
d.sql_text "SQL from blocking session"
FROM v$session a,
v$session b,
v$sql c ,
v$sql d
WHERE a.event ='enq: TX - row lock contention'
AND a.blocking_session=b.sid
AND c.sql_id =a.sql_id
AND d.sql_id =NVL(b.sql_id,b.prev_sql_id);


