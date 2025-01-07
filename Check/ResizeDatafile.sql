select s.tablespace_name, s.file_id, f.file_name,s.bytes/1024/1024 "MB FREE", f.bytes/1024/1024 "MB TOTAL",
'alter database datafile ''' || f.file_name || ''' resize ' || ceil(greatest((f.bytes-s.bytes)/1024/1024,t.INITIAL_EXTENT/1024/1024+1)) || 'M;' RESIZE,
'alter database datafile ''' || f.file_name || ''' autoextend on;'
from dba_free_space s, dba_data_files f, dba_tablespaces t
where s.file_id = f.FILE_ID
and t.tablespace_name = s.tablespace_name
and f.bytes/1024-((s.BLOCK_ID+s.BLOCKS)*(t.block_size/1024)) < 2000
--and t.TABLESPACE_NAME in ('UNDOTBS1')
order by s.bytes/1024/1024 desc
