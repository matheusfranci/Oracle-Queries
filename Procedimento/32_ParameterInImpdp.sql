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
