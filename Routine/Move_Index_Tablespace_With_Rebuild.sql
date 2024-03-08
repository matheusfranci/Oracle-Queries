-- Verificando os indices antes de mover para outra tablespace
COLUMN index_name FORMAT A120
COLUMN table_name FORMAT A60
COLUMN owner FORMAT A20
COLUMN TABLESPACE_NAME FORMAT A30
SELECT index_name, table_name, owner, TABLESPACE_NAME FROM all_indexes where owner='PROTHEUS';

-- Os indices serão movidos da DATA para INDEX
TABLESPACE                     ALLOCATED(MB)   USED(MB)     PCT CONTAINER
------------------------------ ------------- ---------- ------- ------------------------------
PROTHEUS_DATA                            419        331   79.00 protheus_prd
PROTHEUS_INDEX                           105          0     .01 protheus_prd
SYSAUX                                    36         34   93.79 protheus_prd
SYSTEM                                    47         30   62.79 protheus_prd
UNDOTBS1                                  13          0     .00 protheus_prd
USERS                                      1          0     .00 protheus_prd


-- Mudando de schema
ALTER SESSION SET CURRENT_SCHEMA=PROTHEUS;

-- Exemplo de comando para movimentação
			-- Nome do índice						-- Tablespace de destino
ALTER INDEX CD_CRITICA_INDEX2_IX REBUILD TABLESPACE PROTHEUS_INDEX ONLINE;

-- Identificando Indexes
SELECT
segment_name,
segment_type,
tablespace_name
FROM dba_segments 
WHERE owner IN ('SECOPS', 'DEVOPS')
AND SEGMENT_TYPE='INDEX';

-- Criando tablespace
CREATE TABLESPACE SECOPS_INDEX_TBS DATAFILE SIZE 1G AUTOEXTEND ON NEXT 1G;

-- Gerando script
spool index_move_prod.sql
select 'ALTER INDEX ' || OWNER || '.'|| index_name ||' rebuild tablespace DEVOPS_INDEX_TBS online;' 
from dba_indexes 
where owner='DEVOPS'
AND TABLESPACE_NAME = 'DEVOPS_DATA_TBS';
spool off

-- Chamando para execução
@table_move_prod.sql

-- verificando
SELECT
segment_name,
segment_type,
tablespace_name
FROM dba_segments 
WHERE owner IN ('DEVOPS')
AND SEGMENT_TYPE='INDEX'
AND tablespace_name = 'DEVOPS_DATA_TBS';
