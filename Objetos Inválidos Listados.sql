select owner "Owner",

object_name "Objeto",

status "Estado"

from dba_objects

where lower(status) != 'valid'

--and lower(owner) = '{nome_do_owner}'

-- a linha acima pode ser eliminada para

-- que todos os objetos inválidos sejam

-- listados, independente do owner

order by owner, object_name;