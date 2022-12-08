--verificar o archivemodelog
select log_mode from v$database;

-- derrube a instância
shut IMMEDIATE;

-- suba com MOUNT
startup MOUNT;

-- altere o modo de ARCHIVELOG
alter database ARCHIVELOG;

-- abra o banco
alter database open;

--verificar o archivemodelog
select log_mode from v$database;

archive log list

-- ALTERAÇÃO DE DESTINO DE GERAÇÃO DOS ARCHIVES

ALTER SYSTEM SET log_archive_dest_2='LOCATION=C:\Oracle\Archives\Dest2';
ALTER SYSTEM SET log_archive_dest_3='LOCATION=C:\Oracle\Archives\Dest3';
ALTER SYSTEM SET log_archive_dest_4='LOCATION=C:\Oracle\Archives\Dest4';
ALTER SYSTEM SET log_archive_dest_5='LOCATION=C:\Oracle\Archives\Dest5';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='LOCATION=C:\Oracle\Archives\Dest2 MANDATORY ALTERNATE=LOG_ARCHIVE_DEST_3'

-- Consultar os log_archive_dest
select dest_name,status,destination from V$ARCHIVE_DEST;

-- Verificando o log archive format
 select name, value from v$spparameter where name in ('log_archive_dest_2','log_archive_format');

-- Média de produção de gbs de archives
SELECT A.*, 
Round(A.Count#*B.AVG#/1024/1024/1024) Daily_Avg_gb 
FROM 
(SELECT 
To_Char(First_Time,'YYYY-MM-DD') DAY, 
Count(1) Count#, 
Min(RECID) Min#, 
Max(RECID) Max# 
FROM v$log_history 
GROUP 
BY To_Char(First_Time,'YYYY-MM-DD') 
ORDER 
BY 1 
) A, 
(SELECT 
Avg(BYTES) AVG#, 
Count(1) Count#, 
Max(BYTES) Max_Bytes, 
Min(BYTES) Min_Bytes 
FROM 
v$log ) B;
