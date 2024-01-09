-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : tabelas.sql                                                                              #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : Lista o tamanho das tabelas com mais de 1Gb                                              #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
SET SERVEROUTPUT ON
SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG 50000;
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

break on report 
compute sum of data_mb on report 
compute sum of indx_mb on report 
compute sum of lob_mb on report 
compute sum of total_mb on report 

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center 'TAMANHO DE CADA TABELA COM MAIS DE 1G' skip 2
SELECT 
OWNER, table_name,   
         DECODE(partitioned,'/','NO',partitioned) partitioned,   
         num_rows,   
         data_mb,   
         indx_mb,   
         lob_mb,   
         total_mb   
      FROM (SELECT 
      data.owner,
      data.table_name,   
                   partitioning_type  
                  || DECODE (subpartitioning_type,  
                             'NONE', NULL,  
                             '/' || subpartitioning_type)  
                      partitioned,  
                   num_rows,  
                   NVL(data_mb,0) data_mb,  
                   NVL(indx_mb,0) indx_mb,  
                   NVL(lob_mb,0) lob_mb,  
                   NVL(data_mb,0) + NVL(indx_mb,0) + NVL(lob_mb,0) total_mb  
              FROM (  SELECT 
              owner, 
              table_name,  
                             NVL(MIN(num_rows),0) num_rows,  
                             ROUND(SUM(data_mb),2) data_mb  
                        FROM (SELECT owner,
                        table_name, num_rows, data_mb  
                                FROM (SELECT 
                                a.owner,
                                a.table_name,  
                                             a.num_rows,  
                                             b.bytes/1024/1024 AS data_mb  
                                        FROM dba_tables a, dba_segments b  
                                       WHERE a.table_name = b.segment_name))  
                    GROUP BY owner, table_name) data,  
                   (  SELECT 
                   a.owner,
                   a.table_name,  
                             ROUND(SUM(b.bytes/1024/1024),2) AS indx_mb  
                        FROM dba_indexes a, dba_segments b  
                       WHERE a.index_name = b.segment_name  
                    GROUP BY a.owner,a.table_name) indx,  
                   (  SELECT 
                   a.owner,
                   a.table_name,  
                             ROUND(SUM(b.bytes/1024/1024),2) AS lob_mb  
                        FROM dba_lobs a, dba_segments b  
                       WHERE a.segment_name = b.segment_name  
                    GROUP BY a.owner, a.table_name) lob,  
                   user_part_tables part  
             WHERE     data.table_name = indx.table_name(+)  
                   AND data.table_name = lob.table_name(+)  
                   AND data.table_name = part.table_name(+)  
                   AND data.data_mb > 1024)
  ORDER BY total_mb, table_name, owner;