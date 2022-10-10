select to_char(START_TIME,'mm/dd/yy"-"hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy"-"hh24:mi') end_time,
OUTPUT_DEVICE_TYPE,
INPUT_TYPE,
STATUS,
TIME_TAKEN_DISPLAY,
INPUT_BYTES_DISPLAY,
OUTPUT_BYTES_DISPLAY,
elapsed_seconds/3600 hrs
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key;


--Para pegar backups mais demorados que uma hora.
select to_char(START_TIME,'mm/dd/yy"-"hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy"-"hh24:mi') end_time,
OUTPUT_DEVICE_TYPE,
INPUT_TYPE,
STATUS,
TIME_TAKEN_DISPLAY,
INPUT_BYTES_DISPLAY,
OUTPUT_BYTES_DISPLAY,
elapsed_seconds/3600 hrs
from V$RMAN_BACKUP_JOB_DETAILS
where TIME_TAKEN_DISPLAY > '01:00:00'
order by session_key;

select to_char(V$RMAN_BACKUP_JOB_DETAILS.START_TIME,'mm/dd/yy"-"hh24:mi') Início,
to_char(V$RMAN_BACKUP_JOB_DETAILS.END_TIME,'mm/dd/yy"-"hh24:mi') Final,
V$RMAN_BACKUP_JOB_DETAILS.OUTPUT_DEVICE_TYPE as Local,
V$RMAN_BACKUP_JOB_DETAILS.INPUT_TYPE as TIPO,
V$RMAN_BACKUP_JOB_DETAILS.STATUS,
V$RMAN_BACKUP_JOB_DETAILS.TIME_TAKEN_DISPLAY as Duração,
V$INSTANCE.INSTANCE_NAME as Instância,
V$RMAN_BACKUP_JOB_DETAILS.INPUT_BYTES_DISPLAY,
V$RMAN_BACKUP_JOB_DETAILS.OUTPUT_BYTES_DISPLAY,
V$RMAN_BACKUP_JOB_DETAILS.elapsed_seconds/3600 hrs
from V$RMAN_BACKUP_JOB_DETAILS, V$INSTANCE
order by START_TIME desc;
