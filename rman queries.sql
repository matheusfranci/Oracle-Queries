--Verificação
crosscheck backups;

--Verificação de obsoletos
report obsolete;

-- Exclusão
delete obsolete;

-- Verificar schemas do cdb e pdb
report schema

-- Backup de tudo(pdbs e cdbs) com exceção dos arquivelogs
BACKUP DATABASE;
BACKUP FULL DATABASE;

-- Backup de tudo(pdbs e cdbs) com arquivelogs
BACKUP DATABASE PLUS ARCHIVELOG;
BACKUP FULL DATABASE PLUS ARCHIVELOG;

--Backups apenas dos archivelogs
BACKUP ARCHIVELOG ALL;

--Backup apenas do cdbroot
BACKUP DATABASE root;
BACKUP DATABASE "CDB$ROOT";
BACKUP PLUGGABLE DATABASE "CDB$ROOT";

--Backup apenas do pdb
BACKUP PLUGGABLE DATABASE ORCLPDB;
BACKUP PLUGGABLE DATABASE ORCLPDB, PDBTESTDBA;

--Restore
RESTORE DATABASE;
RESTORE PLUGGABLE DATABASE ORCLPDB;
RESTORE TABLESPACE;
RESTORE TABLE;
RESTORE DATABASE SKIP FOREVER TABLESPACE ABCTSDT000,ABCTSIX000,ATETSDT000,ATETSIX000;
