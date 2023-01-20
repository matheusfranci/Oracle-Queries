select 'Hostname : ' || host_name ,'Instance Name : ' || instance_name ,'Started At : ' || to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') stime ,'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' || trunc( 24*((sysdate-startup_time) - trunc(sysdate-startup_time))) || ' hour(s) ' || mod(trunc(1440*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' minute(s) ' || mod(trunc(86400*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' seconds' uptime from sys.v_$instance;

SELECT database_name, 
TO_CHAR(logon_time, 'DD-MM-YYYY HH24:MI:SS') 
FROM v$session WHERE program LIKE '%PMON%';
