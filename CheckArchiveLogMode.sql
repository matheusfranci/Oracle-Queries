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
ALTER SYSTEM SET log_archive_dest_1='LOCATION=C:\oracle_19c\WINDOWS.X64_193000_db_home\rdbms\archive_dir_01';
