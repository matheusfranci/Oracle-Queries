-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : reporta-backup-rman.sql                                                                  #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 29/11/2023		                                                                         #
-- PROPOSITO  : exibe a execução dos backups via rman                                                    #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
SET SERVEROUTPUT ON
SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG 50000;
SET FEEDBACK OFF
set heading on
set termout on
set colsep |
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center 'BACKUP FULL ULTIMO DIA' skip 2
SELECT     bst.backup_type tipo_de_backup
         , bst.controlfile_included backup_controlfile
		 , bst.INCREMENTAL_LEVEL nivel_incremental 
         , substr(RBJD.output_device_type,1,8) Destino
         , substr(RBJD.status,1,10) status
         , TO_CHAR (RBJD.START_TIME, 'DY') Dia
         , RBJD.START_TIME Hr_Inicio
         , RBJD.END_TIME Hr_fim
         , substr(RBJD.time_taken_display,1,10) duracao
        , ROUND (RBJD.INPUT_BYTES / 1024 / 1024 / 1024, 1) input_bytes_gb
         , ROUND (RBJD.OUTPUT_BYTES / 1024 / 1024 / 1024, 1) output_bytes_gb
        , ROUND (RBJD.INPUT_BYTES_PER_SEC / 1024 / 1024, 1) "input mb/s"
         , ROUND (RBJD.OUTPUT_BYTES_PER_SEC / 1024 / 1024, 1) "OUTPUT mb/s"
FROM       v$rman_backup_job_details RBJD
INNER JOIN V$BACKUP_SET_DETAILS BST
ON RBJD.SESSION_KEY = BST.SESSION_KEY 
AND RBJD.SESSION_RECID = BST.SESSION_RECID
AND RBJD.SESSION_STAMP = BST.SESSION_STAMP
WHERE  bst.backup_type = 'D'
AND RBJD.start_time >= TRUNC (SYSDATE - 1)
ORDER BY   RBJD.start_time DESC;


ttitle center 'BACKUP INCREMENTAL ULTIMO DIA' skip 2
SELECT     bst.backup_type tipo_de_backup
         , bst.controlfile_included backup_controlfile
		 , bst.INCREMENTAL_LEVEL nivel_incremental
         , substr(RBJD.output_device_type,1,8) Destino
         , substr(RBJD.status,1,10) status
         , TO_CHAR (RBJD.START_TIME, 'DY') Dia
         , RBJD.START_TIME Hr_Inicio
         , RBJD.END_TIME Hr_fim
         , substr(RBJD.time_taken_display,1,10) duracao
        , ROUND (RBJD.INPUT_BYTES / 1024 / 1024 / 1024, 1) input_bytes_gb
         , ROUND (RBJD.OUTPUT_BYTES / 1024 / 1024 / 1024, 1) output_bytes_gb
        , ROUND (RBJD.INPUT_BYTES_PER_SEC / 1024 / 1024, 1) "input mb/s"
         , ROUND (RBJD.OUTPUT_BYTES_PER_SEC / 1024 / 1024, 1) "OUTPUT mb/s"
FROM       v$rman_backup_job_details RBJD
INNER JOIN V$BACKUP_SET_DETAILS BST
ON RBJD.SESSION_KEY = BST.SESSION_KEY 
AND RBJD.SESSION_RECID = BST.SESSION_RECID
AND RBJD.SESSION_STAMP = BST.SESSION_STAMP
WHERE  bst.backup_type = 'I'
AND RBJD.start_time >= TRUNC (SYSDATE - 1)
ORDER BY   RBJD.start_time DESC;


ttitle center 'BACKUP ARCHIVE ULTIMO DIA' skip 2
SELECT     bst.backup_type tipo_de_backup
         , bst.controlfile_included backup_controlfile
         , substr(RBJD.output_device_type,1,8) Destino
         , substr(RBJD.status,1,10) status
         , TO_CHAR (RBJD.START_TIME, 'DY') Dia
         , RBJD.START_TIME Hr_Inicio
         , RBJD.END_TIME Hr_fim
         , substr(RBJD.time_taken_display,1,10) duracao
        , ROUND (RBJD.INPUT_BYTES / 1024 / 1024 / 1024, 1) input_bytes_gb
         , ROUND (RBJD.OUTPUT_BYTES / 1024 / 1024 / 1024, 1) output_bytes_gb
        , ROUND (RBJD.INPUT_BYTES_PER_SEC / 1024 / 1024, 1) "input mb/s"
         , ROUND (RBJD.OUTPUT_BYTES_PER_SEC / 1024 / 1024, 1) "OUTPUT mb/s"
FROM       v$rman_backup_job_details RBJD
INNER JOIN V$BACKUP_SET_DETAILS BST
ON RBJD.SESSION_KEY = BST.SESSION_KEY 
AND RBJD.SESSION_RECID = BST.SESSION_RECID
AND RBJD.SESSION_STAMP = BST.SESSION_STAMP
WHERE  bst.backup_type = 'L'
AND RBJD.start_time >= TRUNC (SYSDATE - 1)
ORDER BY   RBJD.start_time DESC;


ttitle center 'Lista erro nos backups' skip 2
SELECT  DECODE (STATUS, 'FAILED',       'ERRO_NO_BACKUP_FULL_RMAN', 
                        'COMPLETED',    'BACKUP_COMPLETO_FULL_RMAN'), COMMAND_ID
FROM       v$rman_backup_job_details 
WHERE  input_type ='DB FULL'
AND start_time >= TRUNC (SYSDATE - 1)
and status = 'FAILED'
and SESSION_STAMP NOT IN 
(select SESSION_STAMP from gv$rman_output 
where OUTPUT = 'ORA-00245: control file backup failed; target is likely on a local file system') ;   


ttitle center 'Verifica se o backup datapump esta em execucao' skip 2
select x.job_name,b.state,b.job_mode,b.degree
, x.owner_name,z.sql_text, p.message
, p.totalwork, p.sofar
, round((p.sofar/p.totalwork)*100,2) done
, p.time_remaining
from dba_datapump_jobs b
left join dba_datapump_sessions x on (x.job_name = b.job_name)
left join v$session y on (y.saddr = x.saddr)
left join v$sql z on (y.sql_id = z.sql_id)
left join v$session_longops p ON (p.sql_id = y.sql_id)
WHERE y.module='Data Pump Worker'
AND p.time_remaining > 0;