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
