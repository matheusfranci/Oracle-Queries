-- Descobrindo a tablespace da tabela
select tablespace_name from all_tables where owner = 'CONSINCO' and table_name = 'MRL_CONTROLEQTDEESTOQUE';

-- Descobrindo o tamanho da tabela
select segment_name,segment_type,bytes/1024/1024 MB
 from dba_segments
 where segment_type='TABLE' and segment_name='MRL_CONTROLEQTDEESTOQUE';
 
 -- Descobrindo o número de registros
 select count(*) from table_name;
