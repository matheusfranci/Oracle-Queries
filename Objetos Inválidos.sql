select

owner,

decode(object_type,null,'===========================>',object_type) as "OBJECT_TYPE",

count(object_type) as "TOTAL",

decode(grouping(owner),0,null,1,'Total de objectos invalidos.') as " "

from dba_objects where status <> 'VALID'

group by rollup (owner, object_type)

order by owner, object_type desc;