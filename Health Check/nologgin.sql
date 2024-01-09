-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : nologgin.sql                                                                             #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024			                                                                         #
-- PROPOSITO  : tabelas em nologgin                                                                      #
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
SET lines 200
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

ttitle center 'Relatorio de CHECK DAS TABELAS EM NOLOGGIN' skip 2
select owner, count(*)  FROM DBA_TABLES WHERE LOGGING != 'YES' and TEMPORARY != 'Y' group by owner  ;