select
        name    "Estat�stica",
        value   "Valor"
from
        v$sysstat
where
        name LIKE '%workarea%'