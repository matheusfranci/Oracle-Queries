col tablespace_name format a16;
col file_name format a36;
select file_name,
tablespace_name,
ROUND(bytes/1024/1024) AS currentbytesmb,
ROUND(maxbytes/1024/1024) as mbmaxsize from dba_data_files
order by tablespace_name, file_name;
