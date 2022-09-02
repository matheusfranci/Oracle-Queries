select owner "Owner",
object_name "Objeto",
status "Estado"
from dba_objects
where lower(status) != 'valid'
order by owner, object_name;
