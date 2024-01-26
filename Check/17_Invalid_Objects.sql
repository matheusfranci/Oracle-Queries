select
owner,
decode(object_type,null,'===========================>',object_type) as "OBJECT_TYPE",
count(object_type) as "TOTAL",
decode(grouping(owner),0,null,1,'Total de objectos invalidos.') as " "
from dba_objects where status <> 'VALID'
group by rollup (owner, object_type)
order by owner, object_type desc;


-- Multitenant no cdb
col name for a35
col owner for a35
col object_type for a50
select t.con_id,
p.name,
t.owner,
decode(t.object_type,null,'===========================>',object_type) as "OBJECT_TYPE",
count(t.object_type) as "TOTAL",
decode(grouping(t.owner),0,null,1,'Total de objectos invalidos.') as " "
from cdb_objects t ,v$containers p
where p.con_id = t.con_id and t.status = 'INVALID' 
group by rollup (t.con_id, p.name, t.owner, t.object_type)
order by t.owner, t.object_type desc;
