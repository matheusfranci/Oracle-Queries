SELECT sid,serial#,inst_id,process,osuser,schemaname,machine,status,program,sql_id,sql_exec_start,
to_char(logon_time,'dd-mm-yy hh:mi:ss AM')"Logon Time",
ROUND((SYSDATE-LOGON_TIME)*(24*60),1) as LOGGED_ON_MIN,
ROUND(LAST_CALL_ET/60,1) as CURRENT_SQL_MIN
From gv$session
WHERE STATUS='ACTIVE'
AND USERNAME IS NOT NULL
AND TYPE = 'USER'
and ROUND(LAST_CALL_ET/60,1) > 5 -- more than 5 minutes
ORDER BY LAST_CALL_ET DESC ;
