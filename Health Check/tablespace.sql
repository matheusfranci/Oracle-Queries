-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : tablespace.sql                                                                           #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : Tamanho das tablespaces                                                                  #
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
SET lines 200
set markup html on spool on entmap off

column "Tablespace" format a22
column "Used MB"    format 99,999,999
column "Free MB"    format 99,999,999
column "Total MB"   format 99,999,999
column "Pct. Free %"   format 99,999,999
column "Max extend MB"   format 99,999,999
column "Pct. Extend %"   format 99,999,999

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center 'Datafiles' skip 2
select a.FILE_ID, SUBSTR(a.file_name,2,100), a.TABLESPACE_NAME, (a.bytes/1024)/1024 "SIZE MB", (a.MAXBYTES/1024)/1024 "MAX SIZE MB", b.BIGFILE  
from dba_data_files a , DBA_TABLESPACES b
where a.TABLESPACE_NAME = b.TABLESPACE_NAME order by a.FILE_ID;


ttitle center 'ESTADO DAS TABLESPACES' skip 2
select
   fs.tablespace_name                                               "Tablespace",
   round(df.totalspace - fs.freespace)                              "Used MB",
   round(fs.freespace)                                              "Free MB",
   round(100 * (fs.freespace / df.totalspace))                      "Pct. Free %",
   round(df.totalspace)                                             "Total MB",
   round(tb.maxbytes)                                               "Max extend MB"
   --, round(100 - (100 * (df.totalspace / tb.maxbytes)))           "Pct. Extend %"
   from
   (select tablespace_name, sum(bytes/1024)/1024 TotalSpace from dba_data_files
   group by tablespace_name) df,
   (select tablespace_name, sum(bytes/1024)/1024 FreeSpace  from dba_free_space
   group by tablespace_name) fs,
   (select tablespace_name, sum(maxbytes/1024)/1024 maxbytes from dba_data_files
   group by tablespace_name) tb
where 
   df.tablespace_name = fs.tablespace_name 
   and
   df.tablespace_name = tb.tablespace_name order by "Max extend MB" asc; 
   
  
ttitle center 'ESTADO DAS TABLESPACES TEMPORARIAS' skip 2
select d.tablespace_name
      ,trunc(nvl(a.bytes/1024/1024/1024, 0)) Tamanho_Gb
      ,nvl(t.bytes/1024/1024, 0) Usado_MB
      ,round(nvl(t.bytes / a.bytes * 100, 0), 2)||' %' "Percentual usado"
  from dba_tablespaces d
      ,(select tablespace_name, sum(bytes) bytes
          from dba_temp_files
        group by tablespace_name) a
      ,(select ss.tablespace_name
              ,sum(ss.used_blocks * ts.blocksize) bytes  
          from v$sort_segment ss
              ,sys.ts$ ts
         where ss.tablespace_name = ts.name
        group by ss.tablespace_name) t  
 where d.tablespace_name = a.tablespace_name(+)
   and d.tablespace_name = t.tablespace_name(+)
   and d.extent_management like 'LOCAL'
   and d.contents like 'TEMPORARY';   


ttitle center 'TAMANHO DA INSTANCIA' skip 2
select (select sum(bytes/1024)/1024 from dba_data_files) "Tamanho total do banco", (select sum(bytes/1024)/1024 from SYS.DBA_SEGMENTS) "Tamanho usado usado do banco" from dual;
