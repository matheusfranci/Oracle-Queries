col tablespace_name format a16;
col file_name format a36;
select file_name,
tablespace_name,
ROUND(bytes/1024/1024) AS currentbytesmb,
ROUND(maxbytes/1024/1024) as mbmaxsize from dba_data_files
order by tablespace_name, file_name;


-- Check data de criação do datafile
col v$datafile.name format a16;
col v$datafile.creation_time format a36;
col dba_data_files.tablespace_name format a36;
select Distinct v$datafile.name,
v$datafile.creation_time
from v$datafile
order by creation_time desc;
