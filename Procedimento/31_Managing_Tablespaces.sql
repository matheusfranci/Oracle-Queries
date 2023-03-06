-- Veririficando informações
desc DBA_TABLESPACES
desc v$tablespace
desc DBA_DATA_FILES
desc DBA_FREE_SPACE
select name from v$tablespace;
select tablespace_name from dba_tablespaces;
select ENCRYPTED from DBA_TABLESPACES;
select ENCRYPT_IN_BACKUP from v$tablespace;

SET LINESIZE 150
SELECT TABLESPACE_NAME "TABLESPACE",
INITIAL_EXTENT "INITIAL_EXT",
NEXT_EXTENT "NEXT_EXT",
MIN_EXTENTS "MIN_EXT",
MAX_EXTENTS "MAX_EXT",
PCT_INCREASE
FROM DBA_TABLESPACES;

SELECT STATUS,SEGMENT_SPACE_MANAGEMENT
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME='DBAOCM_TBS';
SELECT FILE_ID,FILE_NAME,ONLINE_STATUS
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'DBAOCM_TBS'
ORDER BY FILE_ID ASC;

-- Verificando o tablespace temporário default do database e alterando para um novo tablespace temporário
SELECT PROPERTY_NAME, PROPERTY_VALUE FROM DATABASE_PROPERTIES WHERE
PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE';

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;

-- Alternando estados do tablespace
ALTER TABLESPACE users OFFLINE NORMAL;
ALTER TABLESPACE users ONLINE;
ALTER TABLESPACE users READ ONLY;
ALTER TABLESPACE users READ WRITE;

-- Adicionando um data file a um tablespace(utilizando OMF)
ALTER TABLESPACE lmtbsb ADD DATAFILE SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 32767M;

-- Adicionando um data file a um tablespace(sem OMF)
ALTER TABLESPACE lmtbsb ADD DATAFILE '/u02/oradata/ORCL/lmtbsb_02.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M
MAXSIZE 32767M;

-- Redimensionando um bigfile tablespace
ALTER TABLESPACE bigtbs RESIZE 20M;

-- Redimensionando um datafile de um smallfile tablespace
ALTER DATABASE DATAFILE
'/u03/oradata/ORCL/9E7F824D52E23D1EE0530A38A8C034BF/datafile/o1_mf_usersts_h62zq41v_.dbf'
Resize 100M;

-- Drop de um tablespace
DROP TABLESPACE users INCLUDING CONTENTS AND DATAFILES;

-- Consultando temp files de um determinado tablespace temporário
select file_name
from dba_temp_files
Where tablespace_name='TEMP2';

-- Adicionando um temp file um tablespace temporário
ALTER TABLESPACE TEMP2
ADD TEMPFILE
'/u02/oradata/ORCL/9E7F824D52E23D1EE0530A38A8C034BF/tempfile/TEMP2_2.dbf' SIZE 18M REUSE;

-- Drop de um temp file
ALTER DATABASE TEMPFILE '/u02/oradata/ORCL/9E7F824D52E23D1EE0530A38A8C034BF/tempfile/TEMP2_2.dbf'
DROP INCLUDING DATAFILES;

-- Drop do tablespace temporário(não é possível dropar o tablespace default)
DROP TABLESPACE temp2 INCLUDING CONTENTS AND DATAFILES;

-- Desabilitando o auto extend de um data file
ALTER DATABASE DATAFILE
'/u03/oradata/ORCL/9E7F824D52E23D1EE0530A38A8C034BF/datafile/o1_mf_usersts_h62zq41v_.dbf' autoextend off;

-- Renomeando um tablespace
ALTER TABLESPACE users RENAME TO usersts;

-- Movendo um data file online(filesystem para filesystem)
alter database move datafile '/u02/oradata/ORCL/DATAFILE/teste01.dbf'
to '/u03/oradata/ORCL/DATAFILE/teste01.dbf';

select name, STATUS from v$datafile where name like '%teste01%';

-- Você ainda pode utilizar o file id do data file para copiá-lo:
ALTER DATABASE MOVE DATAFILE 5 TO '/u02/oradata/ORCL/DATAFILE/teste01.dbf';

-- Movendo um data file online do filesystem para ASM
alter database move datafile '/u02/oradata/ORCL/DATAFILE/teste01.dbf'
to '+DATAC1';

-- Movendo um data file online do ASM para filesystem
alter database move datafile '+DATAC1/ORCL/DATAFILE/teste01.dbf'
to '/u02/oradata/ORCL/DATAFILE/teste01.dbf';

-- Renomeando um data file online
alter database move datafile '/u02/oradata/ORCL/DATAFILE/orclteste.dbf'
to '/u02/oradata/ORCL/DATAFILE/teste01.dbf';
