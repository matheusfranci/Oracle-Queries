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



-- All session
select
   ash.sql_id,
   count(*)
from
   v$active_session_history ash,
   v$event_name evt
where
   ash.sample_time > sysdate - 1/24/60
and
   ash.session_state = 'WAITING'
and
   ash.event_id = evt.event_id
and
   evt.wait_class = 'User I/O'
group by
   sql_id
order by
   count(*) desc;
