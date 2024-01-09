-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : parameter.sql                                                                            #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : consulta os parametros da instancia                                                      #
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

set heading on


column "name" format a35
column "value"    format a45
column "ISDEFAULT"    format a10
ttitle center 'PARAMETROS' skip 2
select name, value , ISDEFAULT as "Parametro Default", description as "descricao do parametro" from v$parameter;