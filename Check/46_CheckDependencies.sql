select distinct * 
from all_dependencies a
start with a.name in ('REINF_XML_UTIL_PKG',
'REINF_UTIL_PKG',
'V_REINF_DETALHE_EVENTO_GERADO',
'COR_RETORNA_PFJ_MATRIZ',
'V_REINF_PENDENTE_GER_DETALHE',
'COR_LE_INICIALIZACAO')
connect by NOCYCLE prior a.name = a.referenced_name;
