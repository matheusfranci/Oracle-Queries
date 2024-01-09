-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : constraints.sql                                                                          #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : VERIFICA AS CONSTRAINTS                                                                  #
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

column "owner" format a16
column "constraint_name"    format a32
column "constraint_type"    format a2
column "table_name"   format a26
column "status%"   format a15
column "validated"  format a15


ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

ttitle center 'CONSTRAINTS NOVALIDATED E DESABILITADAS (PROVAVEIS LIXOS)' skip 2
select owner, constraint_name, constraint_type, table_name, status, validated from dba_constraints WHERE 
owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS',
'EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA') AND
validated != 'VALIDATED' AND 
STATUS = 'DISABLED' order by 1,3,2;


ttitle center 'CONSTRAINTS NOVALIDATED E HABILITADAS (GAMBIARRA)' skip 2
select owner, constraint_name, constraint_type, table_name, status, validated from dba_constraints WHERE 
owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS','EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA') AND
validated != 'VALIDATED' AND 
STATUS != 'DISABLED' 
order by 1,3,2;


ttitle center 'CONSTRAINTS DESABILITADAS' skip 2
select owner, constraint_name, constraint_type, table_name, status, validated from dba_constraints WHERE 
owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS','EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA') AND
STATUS = 'DISABLED' 
order by 1,3,2;