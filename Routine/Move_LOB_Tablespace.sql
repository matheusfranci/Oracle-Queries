-- Identificando Lobs
SELECT
segment_name,
segment_type,
tablespace_name
FROM dba_segments 
WHERE owner IN ('SECOPS', 'DEVOPS')
AND SEGMENT_TYPE='LOBSEGMENT';

-- Criando tablespace
CREATE TABLESPACE DEVSECOPS_LOB_TBS DATAFILE SIZE 1G AUTOEXTEND ON NEXT 1G;

-- Gerando script
SELECT   'alter table '  
|| t.owner 
|| '.'  
|| t.table_name 
|| ' move lob ('
|| column_name|| ') store as (tablespace DEVSECOPS_LOB_TBS);' CMD
FROM dba_lobs l, dba_tables t
WHERE     l.owner = t.owner
AND l.table_name = t.table_name
AND l.SEGMENT_NAME IN
(SELECT segment_name FROM dba_segments WHERE segment_type = 'LOBSEGMENT' AND OWNER IN ('DEVOPS','SECOPS') AND tablespace_name IN ('SECOPS_TBS', 'DEVOPS_DATA_TBS'))
AND l.owner IN ('SECOPS', 'DEVOPS')
ORDER BY t.owner, t.table_name;
