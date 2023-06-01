alter session set NLS_DATE_FORMAT='dd-mm-yy hh24:mi:ss';
accept DATA prompt "DATA(dd-mm-yy): "
select inst_id, COMPLETION_TIME,  sequence# , backup_count
from gv$archived_log 
--where trunc(COMPLETION_TIME)=nvl(to_date('&DATA'),trunc(sysdate))
order by 1,2,3;
