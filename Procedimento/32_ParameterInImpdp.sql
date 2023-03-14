 SELECT
a.ksppinm Param ,
b.ksppstvl SessionVal ,
c.ksppstvl InstanceVal,
a.ksppdesc Descr
FROM
x$ksppi a ,
x$ksppcv b ,
x$ksppsv c
WHERE
a.indx = b.indx AND
a.indx = c.indx AND
a.ksppinm LIKE '/_optimizer_compute_index_stats' escape '/'
/ 

_optimizer_compute_index_stats
TRUE
TRUE
force index stats collection on index creation/rebuild

alter system set "_optimizer_compute_index_stats"=FALSE;


select 'ALTER SYSTEM SET STREAMS_POOL_SIZE='||(max(to_number(trim(c.ksppstvl)))+67108864)||' SCOPE=SPFILE;' 
from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c 
where a.indx = b.indx 
and a.indx = c.indx 
and lower(a.ksppinm) 
in ('__streams_pool_size','streams_pool_size'); 

ALTER SYSTEM SET STREAMS_POOL_SIZE=100M SCOPE=both;
