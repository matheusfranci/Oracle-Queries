select owner "Owner",
object_name "Objeto",
Object_type "Tipo",
status "Estado",
created "Criado em"
from dba_objects
where lower(status) != 'valid'
order by owner, object_name;
