-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : Indexes.sql                                                                              #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024			                                                                         #
-- PROPOSITO  : Check de indexes                                                                         #
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


ttitle center 'NECESSITA COLETA DE ESTATISTICA' skip 2
select OWNER, INDEX_NAME, INDEX_TYPE, TABLE_NAME, STATUS from dba_indexes 
where status IN ('NULL', 'N/A');

	
ttitle center 'INDICES INVALID' skip 2
select table_owner as owner
      ,table_name
      ,index_name
      ,'alter index ' || table_owner || '.' || index_name || ' rebuild;' as comando
from  dba_indexes
where status = 'INVALID'
order by 1,2,3;


ttitle center 'INDICES UNUSABLE' skip 2
select table_owner as owner
      ,table_name
      ,index_name
      ,'alter index ' || table_owner || '.' || index_name || ' rebuild;' as comando
from  dba_indexes
where status = 'UNUSABLE'
order by 1,2,3;


ttitle center 'FK SEM INDICES' skip 2
SELECT tab.owner,
       t.table_name,
       c.constraint_name,
       tab.owner owner_table2,
       c.table_name table2,
       acc.column_name
FROM   dba_constraints t,
       dba_constraints c,
       dba_cons_columns acc,
       dba_tables tab
WHERE  c.r_constraint_name = t.constraint_name
AND    c.table_name = acc.table_name
and    c.table_name = tab.table_name
and     t.table_name = tab.table_name
AND    c.constraint_name = acc.constraint_name
AND    NOT EXISTS (SELECT '1' 
                   FROM  all_ind_columns aid
                   WHERE aid.table_name  = acc.table_name
                   AND   aid.column_name = acc.column_name)
ORDER BY c.table_name;


ttitle center 'INDICES COM MONITORAMENTO ATIVADO' skip 2
select * from DBA_OBJECT_USAGE;