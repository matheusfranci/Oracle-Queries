JOB_NAME=EXPORT_ORION
DIRECTORY=ORACLE_BASE
DUMPFILE=EXPORT_ORCLPDB.dmp
FULL=Y

expdp system/2022@orclpdb parfile=C:\oracle_19c\expdp.par logfile=export.log


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
