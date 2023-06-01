prompt Still running

 

set lines 150
col "BACKUP STARTED" for a25
SELECT to_char(sysdate,'DD-MON-YY HH24:MI') "DATE",
       to_char(start_time,'DD-MON-YY HH24:MI') "BACKUP STARTED",
         --round(totalwork/1024/1024) "TOTAL(MB)", round(sofar/1024/1024) "RESTORED(MB)", 
         round(elapsed_seconds/60) "ELAPSE (Min)", round(TIME_REMAINING/60) "REMAINING (Min)",
         round(sofar*100/totalwork,2) "Complete%"
  FROM sys.v$session_longops
WHERE OPNAME  = 'dbms_backup_restore'
    OR OPNAME like 'RMAN%'
   AND OPNAME NOT LIKE '%aggregate%'
/
