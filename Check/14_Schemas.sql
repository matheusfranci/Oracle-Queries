-- Listando schemas
select distinct owner schema_name
from dba_segments
where owner in(select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX'))
order by owner;

-- Mudando de schema
ALTER SESSION SET CURRENT_SCHEMA=ZEUSMANAGER;

-- Verificando schema atual
select sys_context( 'userenv', 'current_schema' ) from dual;

-- Tamanho do schema
set linesize 150
set pagesize 5000
col owner for a15
col segment_name for a30
col segment_type for a20
col tablespace_name for a30
clear breaks
clear computes
compute sum of SIZE_IN_GB on report
select owner,sum(bytes)/1024/1024/1024"SIZE_IN_GB" from dba_segments group by owner order by owner;

-- Verificando schemas que não são do próprio oracle database
select distinct
   owner
from
   dba_segments
where
   owner not in (
'SYSTEM', 'XDB', 'SYS', 'TSMSYS', 'MDSYS', 'EXFSYS', 'WMSYS', 'ORDSYS', 'OUTLN', 'DBSNMP', 'CTXSYS', 'APEX_030200','ORDDATA', 'APPQOSSYS', 'SYSMAN');

-- Verificando o tamanho de cada schema que não pertence ao oracle
select distinct
   owner, sum(bytes)/1024/1024/1024"SIZE_IN_GB"
from
   dba_segments
where
   owner not in (
'SYSTEM', 'XDB', 'SYS', 'TSMSYS', 'MDSYS', 'EXFSYS', 'WMSYS', 'ORDSYS', 'OUTLN', 'DBSNMP', 'CTXSYS', 'APEX_030200','ORDDATA', 'APPQOSSYS', 'SYSMAN', 'OLAPSYS', 'AUDSYS', 'OJVMSYS', 'GSMADMIN_INTERNAL', 'DVSYS', 'LBACSYS')
group by owner order by owner;
