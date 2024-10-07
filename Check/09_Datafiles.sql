SET LINESIZE 200
COL file_name FORMAT A100
COL tablespace_name FORMAT A16

SELECT file_name,
       tablespace_name,
       ROUND(bytes/1024/1024) AS currentbytesmb,
       ROUND(maxbytes/1024/1024) AS mbmaxsize
FROM dba_data_files
ORDER BY tablespace_name, file_name;


-- Check data de criação do datafile
col v$datafile.name format a16;
col v$datafile.creation_time format a36;
col dba_data_files.tablespace_name format a36;
select Distinct v$datafile.name,
v$datafile.creation_time
from v$datafile
order by creation_time desc;
