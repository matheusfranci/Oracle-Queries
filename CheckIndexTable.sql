-- Verificação completa em uma tabela de um schema
select      a.owner,a.table_name,a.num_rows,
            a.index_owner,a.index_name,a.last_analyzed,a.status,a.leaf_blocks,a.ini_trans,a.pct_free,
            a.block_size,
            a.idx_key_len, 
            round((a.leaf_blocks - (((a.num_rows-a.min_num_nulls)*a.idx_key_len) / (a.block_size - 66 - (a.ini_trans * 24) - (a.pct_free/100*a.block_size)))),2) extra_blocks,
            round(100 * (1 - ((a.leaf_blocks - (((a.num_rows-a.min_num_nulls)*a.idx_key_len) / (a.block_size - 66 - (a.ini_trans * 24) - (a.pct_free/100*a.block_size)))) / a.leaf_blocks)),2) idx_density
from 
(  select   t.owner,t.table_name,t.num_rows,
            i.owner index_owner,i.index_name,i.last_analyzed,i.status,i.leaf_blocks,i.ini_trans,i.pct_free,
            ts.block_size,
            min(tc.num_nulls)   min_num_nulls,
            sum(tc.avg_col_len) idx_key_len
  from      dba_indexes       i, 
            dba_ind_columns   ic, 
            dba_tables        t,
            dba_tab_columns   tc,
            dba_tablespaces   ts
  where     t.owner           = i.table_owner
  and       t.table_name      = i.table_name
  and       i.owner           = ic.index_owner
  and       i.index_name      = ic.index_name
  and       t.owner           = tc.owner 
  and       t.table_name      = tc.table_name 
  and       tc.owner          = ic.table_owner 
  and       tc.table_name     = ic.table_name 
  and       tc.column_name    = ic.column_name
  and       i.tablespace_name = ts.tablespace_name
  and       i.last_analyzed   is not null
  and       i.leaf_blocks     > 0
  and       t.num_rows        > 0
  and       i.pct_free        > 0
  and       i.partitioned     = 'NO'
  group by  t.owner,t.table_name,t.num_rows,i.owner,i.index_name,i.last_analyzed,i.status,i.leaf_blocks,i.ini_trans,i.pct_free,ts.block_size
) a
where       a.idx_key_len is not null
and         round(100 * (1 - ((a.leaf_blocks - (((a.num_rows-a.min_num_nulls)*a.idx_key_len) / (a.block_size - 66 - (a.ini_trans * 24) - (a.pct_free/100*a.block_size)))) / a.leaf_blocks)),2) < 50
and         round((a.leaf_blocks - (((a.num_rows-a.min_num_nulls)*a.idx_key_len) / (a.block_size - 66 - (a.ini_trans * 24) - (a.pct_free/100*a.block_size)))),2)                               > 1000
and         a.owner = 'CONSINCO' 
and a.table_name='MRL_CUSTODIAFAM'
;

-- Verificação que mostra as colunas
select
   table_name,
   index_name,
   column_name
from
   dba_ind_columns
where
   table_owner='CONSINCO'
   and table_name='MRL_CUSTODIAFAM'
order by
   table_name,
   column_position;
   
   -- Extração de ddl
    select dbms_metadata.get_ddl('INDEX','nomedoindice','CONSINCO') from dual
