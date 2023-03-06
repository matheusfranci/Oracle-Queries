select owner,table_name,round((blocks*8),2)/1024/1024 "size (Gb)" , 
round((num_rows*avg_row_len/1024),2)/1024/1024 "actual_data (Gb)",
(round((blocks*8),2) - round((num_rows*avg_row_len/1024),2))/1024/1024 "wasted_space (Gb)"
from dba_tables
where 
(round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
and 
table_name in 
(select segment_name from (select owner, segment_name, bytes/1024/1024 meg from dba_segments
where 
segment_type = 'TABLE' 
and
owner != 'SYS' and owner != 'SYSTEM' and owner != 'OLAPSYS' and owner != 'SYSMAN' and owner != 'ODM' and owner != 'RMAN' and owner != 'ORACLE_OCM' and owner != 'EXFSYS' and owner != 'OUTLN' and owner != 'DBSNMP' and owner != 'OPS' and owner != 'DIP' and owner != 'ORDSYS' and owner != 'WMSYS' and owner != 'XDB' and owner != 'CTXSYS' and owner != 'DMSYS' and owner != 'SCOTT' and owner != 'TSMSYS' and owner != 'MDSYS' and owner != 'WKSYS' and owner != 'ORDDATA' and owner != 'OWBSYS' and owner != 'ORDPLUGINS' and owner != 'SI_INFORMTN_SCHEMA' and owner != 'PUBLIC' and owner != 'OWBSYS_AUDIT' and owner != 'APPQOSSYS' and owner != 'APEX_030200' and owner != 'FLOWS_030000' and owner != 'WK_TEST' and owner != 'SWBAPPS' and owner != 'WEBDB' and owner != 'OAS_PUBLIC' and owner != 'FLOWS_FILES' and owner != 'QMS'
order by bytes/1024/1024 desc) 
where rownum <= 20)
order by 5 desc;
