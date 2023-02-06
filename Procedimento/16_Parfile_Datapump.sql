JOB_NAME=EXPORT
DIRECTORY=ORACLE_BASE
DUMPFILE=EXPORT_ECOAPP.dmp
FULL=Y

expdp system/2022@ecoapp parfile=C:\oracle_19c\parameterfile.par logfile=export.log

-- Atachar no job e verificar os status
expdp system/2022@ecoapp attach=EXPORT
procedimento usuário/senha@instância attach=nomedojob

select 'ALTER SYSTEM SET STREAMS_POOL_SIZE='||(max(to_number(trim(c.ksppstvl)))+67108864)||' SCOPE=SPFILE;' 
from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c 
where a.indx = b.indx 
and a.indx = c.indx 
and lower(a.ksppinm) 
in ('__streams_pool_size','streams_pool_size');

SQL> show parameter STREAMS_POOL_SIZE
To Change the STREAMS_POOL_SIZE:
SQL> ALTER SYSTEM SET STREAMS_POOL_SIZE=100M SCOPE=both;
System altered.

shut immediate;
startup;
