-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : pcheckdg.sql                                                                             #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 29/11/2023		                                                                         #
-- PROPOSITO  : Check de sincronismo dataguard                                                           #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center 'VERIFICA SINCRONISMO DATA GUARD' skip 2
SELECT   /*SUBSTR (DEST_NAME, 1, 10) 
       , */DATABASE_MODE
       , SUBSTR (RECOVERY_MODE, 1, 8) recov_mode
       , PROTECTION_MODE
       , SUBSTR (DESTINATION, 1, 10) dest
       , ARCHIVED_SEQ#
       , APPLIED_SEQ#
       , SUBSTR (SYNCHRONIZATION_STATUS, 1, 8) sync_status
       , SYNCHRONIZED sync
       , GAP_STATUS
	   , STATUS
FROM     V$ARCHIVE_DEST_STATUS
WHERE    TYPE <> 'LOCAL'
;

set feedback on

