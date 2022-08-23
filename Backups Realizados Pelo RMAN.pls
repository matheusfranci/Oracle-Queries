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
