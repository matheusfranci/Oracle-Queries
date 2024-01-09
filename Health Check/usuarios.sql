-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : usuarios.sql                                                                             #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024		                                                                         #
-- PROPOSITO  : tabelas em nologgin                                                                      #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################

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


ttitle center 'USUARIOS' skip 2
SELECT USERNAME, ACCOUNT_STATUS, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE FROM DBA_USERS;


ttitle center 'QUANTIDADE DE OBJETOS POR USUARIO' skip 2
SELECT OWNER, OBJECT_TYPE, COUNT(*) FROM DBA_OBJECTS GROUP BY OWNER, OBJECT_TYPE ORDER BY OWNER,OBJECT_TYPE;


ttitle center 'OBJETOS INVALIDOS POR USUARIO' skip 2
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE FROM DBA_OBJECTS WHERE STATUS != 'VALID';