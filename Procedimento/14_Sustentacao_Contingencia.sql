Ficção - SUSTENTAÇÃO DA CONTINGÊNCIA

Hoje foi verificado se a cotingência estava sincronizada e o cenário foi esse:

=================================
======= SERVIDOR PRINCIPAL ======
=================================

   THREAD# |  SEQUENCE# | HORAATUAL            | ARCHIVETIME
========== | ========== | ==================== | ====================
         1 |      58401 | 19/01/2023 10:30:16  | 19/01/2023 10:30:11
         1 |      58401 | 19/01/2023 10:30:16  | 19/01/2023 10:30:11


Disconnected from Oracle Database 11g Release 11.2.0.4.0 - 64bit Production
With the Automatic Storage Management option
Connected.

   HOSTNAME     |    INSTANCE     |   STATUS   |  DATABASE_STATUS  |      VERSION      |        UPTIME
=============== | =============== | ========== | ================= | ================= | =====================
Ficção01           | Ficção02           | MOUNTED    | ACTIVE            | 11.2.0.4.0        | Uptime : 166 days(s)
Elapsed: 00:00:00.00


=================================
======= SERVIDOR STAND-BY =======
=================================

   THREAD# |  SEQUENCE# | HORAATUAL            | ARCHIVETIME
========== | ========== | ==================== | ====================
         1 |      37164 | 19/01/2023 10:30:17  | 10/10/2022 10:00:33


Disconnected from Oracle Database 11g Release 11.2.0.4.0 - 64bit Production
With the Automatic Storage Management option

-- MOTIVO DA NÃO SINCRONIA --
Starting recover at 19-JAN-23
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=963 device type=DISK
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 01/19/2023 10:45:14
RMAN-06094: datafile 142 must be restored


Após isso eu entrei no servidor de contingência e apaguei o banco pelo rman:

rman target /

drop database noprompt;

exit;

Criei um pfile do banco de produção e utilizei ele para subir o de contingência
-- PRODUÇÃO -- 

create pfile='/mnt/fs-Ficção-backup/Ficção/Ficção_init_pfile.ora' from spfile;

-- CONTINGÊNCIA -- 

sqlplus / as sysdba

startup nomount pfile='/mnt/fs-Ficção-backup/Ficção/Ficção_init_pfile.ora';

create spfile from  pfile='/mnt/fs-Ficção-backup/Ficção/Ficção_init_pfile.ora';

screen

rman target /

shutdown abort;

startup nomount;


-- CONTINGÊNCIA --
-- Foi necessário criar as pastas /u02/app/oracle/oradata/Ficção01/ e /u03/app/oracle/oradata/Ficção01/ para durante a restauração do 
-- controlfile ser concluida com sucesso, visto que no de produção os controlfiles estão multiplexados nas 3 partições u01, u02 e u03

ORA-19601: output file is control file  (/u02/app/oracle/oradata/Ficção01/control02.ctl)
ORA-19601: output file is control file  (/u03/app/oracle/oradata/Ficção01/control03.ctl)
mkdir -p /u02/app/oracle/oradata/Ficção01/
mkdir -p /u03/app/oracle/oradata/Ficção01/

chgrp oinstall /u03/app/oracle/oradata/Ficção01/
chown oracle /u03/app/oracle/oradata/Ficção01/

chgrp oinstall /u02/app/oracle/oradata/Ficção01/
chown oracle /u02/app/oracle/oradata/Ficção01/

-- Copiei o último controlfile auto gerado que estava no asm, segue procedimento:
-- Entre no usuário grid e a posteriori no asm.

sudo su - grid
asmcmd
cd +data/full_Ficção01/auto/

ASMCMD> cp +data/full_Ficção01/auto/ctl_Ficção01_c-4230324003-20230119-31.bkp /mnt/fs-Ficção-backup/Ficção/auto/

rman target /
RMAN> restore controlfile from '/mnt/fs-Ficção-backup/Ficção/auto/ctl_Ficção01_c-4230324003-20230119-31.bkp';


Starting restore at 19-JAN-23
using channel ORA_DISK_1

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:03
output file name=/u01/app/oracle/oradata/Ficção01/control01.ctl
output file name=/u02/app/oracle/oradata/Ficção01/control02.ctl
output file name=/u03/app/oracle/oradata/Ficção01/control03.ctl
Finished restore at 19-JAN-23

alter database mount;

run
{
catalog start with '/mnt/fs-Ficção-backup/Ficção/full/FULL_Ficção01_20230115_583595_1.BKP' noprompt;
catalog start with '/mnt/fs-Ficção-backup/Ficção/full/FULL_Ficção01_20230116_583595_2.BKP' noprompt;
}

crosscheck backupset ;


run
{
restore database;
SWITCH DATAFILE ALL;
SWITCH TEMPFILE ALL;
}



-- Para verificar a restauração
TTITLE LEFT '% Completed. Aggregate is the overall progress:'
SET LINE 132
SELECT opname, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS "Time", round(sofar/totalwork*100) "% Complete"
  FROM gv$session_longops
 WHERE opname LIKE 'RMAN%'
   AND totalwork != 0
   AND sofar <> totalwork
 ORDER BY 1;
 
