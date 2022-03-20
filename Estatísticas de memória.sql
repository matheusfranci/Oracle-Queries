select
        name    "Estatística",
        value   "Valor"
from
        v$sysstat
where
        name LIKE '%workarea%'