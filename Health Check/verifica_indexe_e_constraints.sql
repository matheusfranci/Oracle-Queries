-- #######################################################################################################
-- DBA_Corp                                                                                              #
--                                                                                                       #
-- SCRIPT     : verifica_constraints_e_indexes.sql                                                       #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                        #
-- PROPOSITO  : relatorio das constraints e indices                                                      #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
--setup do sqlplus
--
--

set pagesize 100 
set linesize 150
set colsep |
set termout off

set termout on
set markup html on spool on entmap off
-- inicio do relatorio


set heading off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


set heading on

ttitle center 'CONSTRAINTS' skip 2
select a.owner, a.table_name, a.constraint_name, a.constraint_type, a.status, a.deferred, a.validated from dba_constraints a 
where a.owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS','EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA') ;


ttitle center 'COLUNS_CONSTRAINTS' skip 2
select * from dba_cons_columns 
where owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS','EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA');
      

ttitle center 'INDEXES' skip 2
select b.OWNER,b.TABLE_NAME,b.index_name ,b.index_type, b.status from dba_indexes b
where b.table_owner NOT IN ('SYS','SYSTEM','SYSMAN', 'OLAPSYS','APEX_030200','FLOWS_FILES','MDSYS','EXFSYS','SCOTT','ORDSYS','WMSYS','CTXSYS','OWBSYS','AURORA$JIS$UTILITY$','ORDDATA');

