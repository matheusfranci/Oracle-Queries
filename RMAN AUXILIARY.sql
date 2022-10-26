-- Recriação do RM2 como Homologação:

export ORACLE_SID=RM2

sqlplus / as sysdba

select instance_name, status from v$instance;

shutdown abort;

startup mount exclusive;

alter system enable restricted session;

exit;

rman target /

drop database noprompt;

exit;

sqlplus / as sysdba

startup nomount pfile='/home/oracle/initRM2.ora';

create spfile from pfile='/home/oracle/initRM2.ora';

exit

cd /u02/backup/orion/bk/rman/rm

mv FULL_RM_20221022*.BKP ./archive/
mv INC_RM_202210*.BKP ./archive/
mv SPFILE_RM_20221025_400571.BKP ./archive/
cd auto
cp CTL_RM_c-2819490895-20221025-41.BKP ../archive/

screen

rman auxiliary /

duplicate database to RM2
backup location '/u02/backup/orion/bk/rman/rm/archive' nofilenamecheck
DB_FILE_NAME_CONVERT ('+DATA/rm/', '+DATA/rm2/')
LOGFILE
'+DATA/rm2/redo/redo01a.log' SIZE 1G,
'+DATA/rm2/redo/redo02a.log' SIZE 1G,
'+DATA/rm2/redo/redo03a.log' SIZE 1G,
'+DATA/rm2/redo/redo04a.log' SIZE 1G,
'+DATA/rm2/redo/redo05a.log' SIZE 1G,
'+DATA/rm2/redo/redo06a.log' SIZE 1G,
'+DATA/rm2/redo/redo07a.log' SIZE 1G,
'+DATA/rm2/redo/redo08a.log' SIZE 1G noopen;
