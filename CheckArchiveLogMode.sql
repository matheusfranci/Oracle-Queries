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
