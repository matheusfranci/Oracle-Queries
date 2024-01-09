-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : corruption_bl.sql                                                                        #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024			                                                                         #
-- PROPOSITO  : Identifica blocos corrompidos                                                            #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off


ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

ttitle center 'IDENTIFICA BLOCOS CORROMPIDOS' skip 2
SELECT * FROM V$DATABASE_BLOCK_CORRUPTION;

ttitle center 'IDENTIFICA MAPEAMENTO DE BLOCOS CORROMPIDOS (USA O CONTROLFILE)' skip 2
SELECT * FROM V$BACKUP_CORRUPTION;


-- prompt #######  SCRIPT DATABASE VERIFY  #######

-- select 'dbv file='||chr(39)||file_name||chr(39)||' BLOCKSIZE=8192 FEEDBACK=100'  from dba_data_files;


--prompt #######  SCRIPT DE ANALYZE TABLES CASCADE  #######

--SELECT 'ANALYZE TABLE '||OWNER||'.'||TABLE_NAME||' VALIDATE STRUCTURE CASCADE;' FROM DBA_TABLES;
