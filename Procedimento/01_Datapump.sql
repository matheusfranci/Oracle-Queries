-- Criação de diretório do datapump
CREATE OR REPLACE DIRECTORY "DATA_PUMP_DIR14" as '/mnt/FS-RJD1427/DUMPFILES/RJD14/';

-- Grant para o usuário executor poder realizar o datapump expdp
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR14 TO SYSTEM;

-- Verificação do diretório
SELECT OWNER, DIRECTORY_NAME, DIRECTORY_PATH FROM DBA_DIRECTORIES WHERE DIRECTORY_NAME='nomedodiretório';

--expdp
 expdp \"/ as sysdba\" full=y VERSION=12 directory=DATA_PUMP_DIR file=exp_full_rjd14.dmp log=exp_full_rjd14.log exclude=statistics

--IMPDP
impdp system/senha@nomedopdb directory=DATA_PUMP_DIR14 dumpfile=exp_full.dmp logfile=imp_full.log version=11.2.0.4 table_exists_action=replace metrics=yes transform=disable_archive_logging:y exclude=schema:\"IN\(\'E   ASY_2015_2016\',\'ANONYMOUS\',\'CTXSYS\',\'DBSNMP\',\'EXFSYS\',\'LBACSYS\',\'MDSYS\',\'MGMT_VIEW\',\'OLAPSYS\',\'ORDDATA\',\'OWBSYS\',\'ORDPLUGINS\',\'ORDSYS\',\'OUTLN\',\'SI_INFORMTN_SCHEMA\',\'SYSMAN\',\'SYSTEM\',\'WK_TEST\',\'WKSYS\',\'WKPROXY\',\'SYS\',\'WMSYS\',\'XDB\',\'APEX_030200\',\'PERFSTAT\',\'APEX_PUBLIC_USER\',\'SYSAUX\'\)\"


--Lembrar-se das permissões de acesso às pastas.
 
 -- startup restrict aumenta a performance do impdp
