## Lobs
select 'ALTER TABLE '||s.owner||'.'||l.table_name||' MOVE LOB('||l.column_name||') STORE AS (TABLESPACE USERNAME) online;' 
  from dba_segments s, dba_lobs l
 where s.segment_name = l.segment_name
   and s.tablespace_name = 'USERNAME'
   and segment_type='LOBSEGMENT'
   and partition_name is null;

## Tables move
select 'ALTER TABLE '||owner||'.'||table_name||' move tablespace '||'USERNAME online;' from dba_tables where tablespace_name='USERS'and Owner='USERNAME';


## Move / rebuild indexes 
select 'ALTER INDEX '||owner||'.'||index_name||' REBUILD TABLESPACE '||'USERNAME_INDEX parallel 8 online;' 
from dba_indexes where tablespace_name='USERS';


## Lob Index move 
select 'alter table '||owner||'.'||table_name||' move lob ('||column_name||') store as '||SEGMENT_NAME||' (tablespace USERNAME_INDEX);'from dba_lobs where OWNER='USERNAME' and tablespace_name='USERS';

##
Check Lob indexes
select index_name,index_type, table_name,table_type, tablespace_name from dba_indexes where tablespace_name='USERNAME' order by 3;
select index_name,index_type, table_name,table_type, tablespace_name from dba_indexes where owner='USERNAME' and index_type='LOB' and tablespace_name='USERS' order by 3;
