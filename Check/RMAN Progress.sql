select
  sid,
  start_time,
  totalwork
  sofar,
 (sofar/totalwork) * 100 pct_done
from
   v$session_longops
where
   totalwork > sofar
AND
   opname NOT LIKE '%aggregate%'
AND
   opname like 'RMAN%';
