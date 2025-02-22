-- Backup incemental level 1 Monitoria 
SELECT TO_CHAR(START_TIME, 'DD/MM/YYYY HH24:MI:SS') AS START_TIME, 
TO_CHAR(END_TIME, 'DD/MM/YYYY HH24:MI:SS') AS END_TIME, 
TO_CHAR(START_TIME, 'Day') AS DAY, TO_NUMBER(TO_CHAR(START_TIME, 'D')) AS DAY_NUMBER, 
OUTPUT_BYTES_DISPLAY, 
TIME_TAKEN_DISPLAY, 
INPUT_TYPE, 
STATUS 
FROM V$RMAN_BACKUP_JOB_DETAILS 
WHERE OBJECT_TYPE_WEIGHT = 7 
AND TO_NUMBER(TO_CHAR(START_TIME, 'D')) IN (2, 3, 4, 5, 6, 7) 
AND TRUNC(START_TIME) = TRUNC(SYSDATE - 1) -- Retorna somente o de ontem 
AND STATUS = 'FAILED' -- Retorna o backup que ocorreu com falha