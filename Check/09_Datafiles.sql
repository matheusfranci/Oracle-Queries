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
SELECT DISTINCT v$datafile.name,
       v$datafile.creation_time, -- Incluindo a coluna original
       TO_CHAR(v$datafile.creation_time, 'HH24:MI:SS') AS creation_time_hour
FROM v$datafile
ORDER BY v$datafile.creation_time DESC;
